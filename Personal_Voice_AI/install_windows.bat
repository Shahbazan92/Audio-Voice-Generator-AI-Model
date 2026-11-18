@echo off
REM One-click setup for Windows. Creates .venv, installs PyTorch + everything, then starts the app.
setlocal
cd /d "%~dp0"

where py >nul 2>nul
if errorlevel 1 (
  echo Python launcher "py" not found. Install Python 3.11 from https://www.python.org/downloads/ and tick "Add to PATH".
  pause & exit /b 1
)

if not exist .venv (
  py -3.11 -m venv .venv 2>nul || py -3.12 -m venv .venv 2>nul || py -3.10 -m venv .venv
)
if not exist .venv\Scripts\python.exe (
  echo Could not create a virtual environment. You need Python 3.10, 3.11 or 3.12 (NOT 3.13).
  pause & exit /b 1
)

call .venv\Scripts\activate.bat
python -m pip install --upgrade pip

set TORCH_INDEX=https://download.pytorch.org/whl/cpu
where nvidia-smi >nul 2>nul
if not errorlevel 1 (
  echo NVIDIA GPU detected - installing CUDA build of PyTorch.
  set TORCH_INDEX=https://download.pytorch.org/whl/cu124
)

pip install torch==2.5.1 torchaudio==2.5.1 --index-url %TORCH_INDEX%
if errorlevel 1 ( echo PyTorch install failed. & pause & exit /b 1 )

pip install -r requirements-xtts.txt
if errorlevel 1 ( echo Package install failed - copy the error above. & pause & exit /b 1 )

python -c "import torch, torchaudio; from TTS.api import TTS; print('Model stack OK, torch', torch.__version__)"
if errorlevel 1 ( echo Import check failed - copy the error above. & pause & exit /b 1 )

echo.
echo Setup complete. Starting the app...
python -m streamlit run app.py
pause
