#!/bin/bash
# ===============================================================================
# Quick Start Script - Système ML CIAPOL Docker
# Déploiement et test automatisé du système complet
# ===============================================================================

set -e

echo "🚀 CIAPOL ML System - Quick Start"
echo "=================================="
echo ""

# Vérification des prérequis
echo "🔍 Vérification des prérequis..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé"
    exit 1
fi

if ! command -v python &> /dev/null; then
    echo "❌ Python n'est pas installé"
    exit 1
fi

echo "✅ Prérequis validés"
echo ""

# Option de déploiement
echo "Choisissez une option de déploiement:"
echo "1) Déploiement automatisé complet (recommandé)"
echo "2) Déploiement manuel simple"
echo "3) Tests uniquement (si déjà déployé)"
echo "4) Arrêt des services"
echo ""
read -p "Votre choix (1-4): " choice

case $choice in
    1)
        echo "🔄 Lancement du déploiement automatisé..."
        python scripts/deploy-ml-system-docker.py
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ Déploiement terminé avec succès!"
            echo ""
            echo "🧪 Lancement des tests de validation..."
            python scripts/test-ml-system.py
        else
            echo "❌ Échec du déploiement automatisé"
            exit 1
        fi
        ;;
    
    2)
        echo "🔄 Déploiement manuel simple..."
        
        echo "Arrêt des services existants..."
        docker-compose down --remove-orphans
        
        echo "Construction des images..."
        docker-compose build
        
        echo "Démarrage des services..."
        docker-compose up -d
        
        echo "Attente du démarrage des services..."
        sleep 30
        
        echo "✅ Déploiement manuel terminé"
        echo ""
        echo "🧪 Lancement des tests de validation..."
        python scripts/test-ml-system.py
        ;;
    
    3)
        echo "🧪 Lancement des tests uniquement..."
        python scripts/test-ml-system.py
        ;;
    
    4)
        echo "⏹️ Arrêt des services..."
        docker-compose down --remove-orphans
        echo "✅ Services arrêtés"
        exit 0
        ;;
    
    *)
        echo "❌ Option invalide"
        exit 1
        ;;
esac

# Affichage des informations finales
echo ""
echo "🌐 Services disponibles:"
echo "=================================="
echo "• Frontend:              http://localhost:3000"
echo "• ML Dataset Generator:  http://localhost:8001" 
echo "• ML Model Trainer:      http://localhost:8002"
echo "• ML Predictor:          http://localhost:8003"
echo "• StarRocks API:         http://localhost:8000"
echo "• StarRocks:             http://localhost:8030"
echo "• ClearML:               http://localhost:8080"
echo "• DolphinScheduler:      http://localhost:12345"
echo "• SeaTunnel:             http://localhost:5801"
echo "• Pulsar:                http://localhost:3002"
echo ""

echo "📚 Documentation:"
echo "• Guide complet: README-ML-DOCKER.md"
echo "• Tests: python scripts/test-ml-system.py"
echo "• Statut: docker-compose ps"
echo "• Logs: docker-compose logs -f [service]"
echo ""

echo "🎉 Système ML CIAPOL opérationnel!"
echo "Utilisez Ctrl+C pour quitter ce script."
echo ""

# Option de monitoring en temps réel
read -p "Voulez-vous afficher les logs en temps réel? (y/N): " monitor

if [[ $monitor =~ ^[Yy]$ ]]; then
    echo "📊 Monitoring des services (Ctrl+C pour quitter)..."
    docker-compose logs -f
fi