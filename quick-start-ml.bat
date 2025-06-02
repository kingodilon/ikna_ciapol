@echo off
REM ===============================================================================
REM Quick Start Script - Système ML CIAPOL Docker (Windows)
REM Déploiement et test automatisé du système complet
REM ===============================================================================

echo 🚀 CIAPOL ML System - Quick Start
echo ==================================
echo.

REM Vérification des prérequis
echo 🔍 Vérification des prérequis...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker n'est pas installé
    pause
    exit /b 1
)

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose n'est pas installé
    pause
    exit /b 1
)

python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python n'est pas installé
    pause
    exit /b 1
)

echo ✅ Prérequis validés
echo.

REM Option de déploiement
echo Choisissez une option de déploiement:
echo 1) Déploiement automatisé complet (recommandé)
echo 2) Déploiement manuel simple
echo 3) Tests uniquement (si déjà déployé)
echo 4) Arrêt des services
echo.
set /p choice="Votre choix (1-4): "

if "%choice%"=="1" goto deploy_auto
if "%choice%"=="2" goto deploy_manual
if "%choice%"=="3" goto test_only
if "%choice%"=="4" goto stop_services
echo ❌ Option invalide
pause
exit /b 1

:deploy_auto
echo 🔄 Lancement du déploiement automatisé...
python scripts/deploy-ml-system-docker.py
if errorlevel 1 (
    echo ❌ Échec du déploiement automatisé
    pause
    exit /b 1
)

echo.
echo ✅ Déploiement terminé avec succès!
echo.
echo 🧪 Lancement des tests de validation...
python scripts/test-ml-system.py
goto end_info

:deploy_manual
echo 🔄 Déploiement manuel simple...
echo Arrêt des services existants...
docker-compose down --remove-orphans

echo Construction des images...
docker-compose build

echo Démarrage des services...
docker-compose up -d

echo Attente du démarrage des services...
timeout /t 30 /nobreak

echo ✅ Déploiement manuel terminé
echo.
echo 🧪 Lancement des tests de validation...
python scripts/test-ml-system.py
goto end_info

:test_only
echo 🧪 Lancement des tests uniquement...
python scripts/test-ml-system.py
goto end_info

:stop_services
echo ⏹️ Arrêt des services...
docker-compose down --remove-orphans
echo ✅ Services arrêtés
pause
exit /b 0

:end_info
echo.
echo 🌐 Services disponibles:
echo ==================================
echo • Frontend:              http://localhost:3000
echo • ML Dataset Generator:  http://localhost:8001
echo • ML Model Trainer:      http://localhost:8002
echo • ML Predictor:          http://localhost:8003
echo • StarRocks API:         http://localhost:8000
echo • StarRocks:             http://localhost:8030
echo • ClearML:               http://localhost:8080
echo • DolphinScheduler:      http://localhost:12345
echo • SeaTunnel:             http://localhost:5801
echo • Pulsar:                http://localhost:3002
echo.

echo 📚 Documentation:
echo • Guide complet: README-ML-DOCKER.md
echo • Tests: python scripts/test-ml-system.py
echo • Statut: docker-compose ps
echo • Logs: docker-compose logs -f [service]
echo.

echo 🎉 Système ML CIAPOL opérationnel!
echo.

set /p monitor="Voulez-vous afficher les logs en temps réel? (y/N): "
if /i "%monitor%"=="y" (
    echo 📊 Monitoring des services (Ctrl+C pour quitter)...
    docker-compose logs -f
) else (
    echo Appuyez sur une touche pour quitter...
    pause >nul
)