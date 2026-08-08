import os
import subprocess
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import List, Dict, Any
from pathlib import Path

app = FastAPI()

# Enable CORS so local HTML (whether opened via local file or hosted server) can interact
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class CodePayload(BaseModel):
    code: str

class FilePayload(BaseModel):
    path: str  # Relative path from project root, e.g., "riscv_gcc/tst.c"
    content: str

# Directories configurations based on visual tree layout
PROJECT_ROOT = os.path.realpath(os.getcwd())
C_SOURCE_PATH = os.path.join(PROJECT_ROOT, 'riscv_gcc', 'tst.c')
DISASM_FILE_PATH = os.path.join(PROJECT_ROOT, 'riscv_gcc', 'disasm.txt')
IMAGE_PROCESS_DIR = os.path.join(PROJECT_ROOT, 'image_process')

# Helper: Ensure path is safely within the PROJECT_ROOT directory using pathlib
def get_safe_path(relative_path: str) -> str:
    try:
        # Resolve to absolute canonical path, resolving symlinks & standardizing drive letters
        root = Path(PROJECT_ROOT).resolve()
        target = root.joinpath(relative_path).resolve()
        
        # Check if root is an ancestor of target (or target itself)
        if root not in [target] + list(target.parents):
            raise HTTPException(status_code=403, detail="Access denied: Path is outside project directory")
            
        return str(target)
    except HTTPException as he:
        raise he
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid path: {str(e)}")

@app.post("/simulate")
async def run_simulation(payload: CodePayload):
    try:
        # FIX: We no longer unconditionally overwrite 'riscv_gcc/tst.c' here.
        # Since our file explorer saves modifications directly to their actual locations on disk,
        # forcing an overwrite here is redundant and was causing other active files in the editor
        # (like Testbench.v) to overwrite and ruin 'tst.c'.
        
        # Trigger the automate.py simulation script using the already saved filesystem files
        result = subprocess.run(
            ['python', 'automate.py', 'run'], 
            capture_output=True, text=True, cwd=PROJECT_ROOT
        )
        return {"output": result.stdout + "\n" + result.stderr}
    except Exception as e:
        return {"output": f"Backend Error: {str(e)}"}

@app.post("/process-image")
async def process_image_pipeline():
    try:
        # Trigger the image pipeline scripts
        result = subprocess.run(
            ['python', 'automate.py', 'process_image'], 
            capture_output=True, text=True, cwd=PROJECT_ROOT
        )
        return {"output": result.stdout + "\n" + result.stderr}
    except Exception as e:
        return {"output": f"Backend Error: {str(e)}"}

@app.post("/clean")
async def clean_build():
    try:
        result = subprocess.run(
            ['python', 'automate.py', 'clean'], 
            capture_output=True, text=True, cwd=PROJECT_ROOT
        )
        return {"output": result.stdout + "\n" + result.stderr}
    except Exception as e:
        return {"output": f"Backend Error: {str(e)}"}

@app.post("/clean_all")
async def clean_all_build():
    try:
        # If your automate.py does not support clean_all natively, fall back to cleaning.
        result = subprocess.run(
            ['python', 'automate.py', 'clean'], 
            capture_output=True, text=True, cwd=PROJECT_ROOT
        )
        return {"output": result.stdout + "\n" + result.stderr}
    except Exception as e:
        return {"output": f"Backend Error: {str(e)}"}

# Get disassembly code mapping from compiler
@app.get("/disassembly")
async def read_disassembly():
    try:
        if os.path.exists(DISASM_FILE_PATH):
            with open(DISASM_FILE_PATH, 'r') as f:
                content = f.read()
            return {"assembly": content}
        return {"assembly": "[WARN] disasm.txt file is missing or compiles have not run yet."}
    except Exception as e:
        return {"assembly": f"[ERROR] Could not read file: {str(e)}"}

# Handle direct image upload over server
@app.post("/upload-image")
async def upload_image(file: UploadFile = File(...)):
    try:
        # Ensure targeted image directory exists
        os.makedirs(IMAGE_PROCESS_DIR, exist_ok=True)
        target_path = os.path.join(IMAGE_PROCESS_DIR, "input.png")
        
        # Save content
        with open(target_path, "wb") as buffer:
            buffer.write(await file.read())
            
        return {"detail": "input.png overwritten in image_process directory"}
    except Exception as e:
        return {"detail": f"Upload failure: {str(e)}"}

# Endpoint serving processed images dynamically with cache management
@app.get("/image/{image_name}")
async def serve_pipeline_image(image_name: str):
    # Route for retrieving workspace images securely
    try:
        image_path = get_safe_path(os.path.join('image_process', image_name))
        if os.path.exists(image_path):
            return FileResponse(image_path)
    except HTTPException as he:
        raise he
    except Exception:
        pass
    return {"error": "Image not found"}

# ================= FILE MANAGER ENDPOINTS =================

@app.get("/files")
async def list_files():
    """
    Returns a recursive tree of files inside the project directory,
    excluding heavy build artifacts, temporary folders, or hidden files.
    """
    exclude_dirs = {'.git', '__pycache__', 'obj_dir', '.pytest_cache', 'venv', 'env'}
    exclude_extensions = {'.o', '.elf', '.bin', '.vcd', '.png', '.jpg', '.jpeg'}

    def build_tree(path: str) -> List[Dict[str, Any]]:
        tree = []
        try:
            for entry in os.scandir(path):
                # Ignore hidden files/folders
                if entry.name.startswith('.'):
                    continue
                
                if entry.is_dir():
                    if entry.name in exclude_dirs:
                        continue
                    tree.append({
                        "name": entry.name,
                        "type": "directory",
                        "path": os.path.relpath(entry.path, PROJECT_ROOT),
                        "children": build_tree(entry.path)
                    })
                elif entry.is_file():
                    _, ext = os.path.splitext(entry.name)
                    if ext.lower() in exclude_extensions:
                        continue
                    tree.append({
                        "name": entry.name,
                        "type": "file",
                        "path": os.path.relpath(entry.path, PROJECT_ROOT)
                    })
        except Exception as e:
            import traceback
            traceback.print_exc()
            raise HTTPException(status_code=500, detail=f"Failed to read directory tree: {str(e)}")
        
        # Sort directories first, then files alphabetically
        tree.sort(key=lambda x: (x["type"] == "file", x["name"].lower()))
        return tree

    return {"files": build_tree(PROJECT_ROOT)}

@app.get("/file")
async def read_file(path: str):
    """
    Reads and returns the text contents of a target file inside the project workspace.
    Usage: GET /file?path=riscv_gcc/crt0.S
    """
    try:
        safe_path = get_safe_path(path)
        if not os.path.exists(safe_path):
            raise HTTPException(status_code=404, detail="File not found")
        if not os.path.isfile(safe_path):
            raise HTTPException(status_code=400, detail="Target path is not a file")
            
        with open(safe_path, 'r', encoding='utf-8', errors='ignore') as f:
            content = f.read()
        return {"path": path, "content": content}
    except HTTPException as he:
        raise he
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Failed to read file: {str(e)}")

@app.post("/file")
async def write_file(payload: FilePayload):
    """
    Writes or updates file contents. Automatically creates missing parent directories.
    Usage: POST /file with JSON body containing path and content.
    """
    try:
        safe_path = get_safe_path(payload.path)
        
        # Create directories if they do not exist
        os.makedirs(os.path.dirname(safe_path), exist_ok=True)
        
        with open(safe_path, 'w', encoding='utf-8') as f:
            f.write(payload.content)
            
        return {"status": "success", "detail": f"File {payload.path} successfully written."}
    except HTTPException as he:
        raise he
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Failed to write file: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    # Make sure this runs from the root of your project directory
    uvicorn.run(app, host="127.0.0.1", port=8000)