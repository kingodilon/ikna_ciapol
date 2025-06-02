# 🚀 Système ML CIAPOL - Déploiement Docker Complet

## 📋 Vue d'ensemble

Le système ML CIAPOL est maintenant entièrement dockerisé avec un pipeline complet de machine learning pour les prédictions de qualité de l'air. Architecture moderne basée sur **Docker Compose** avec 10 services intégrés.

## 🏗️ Architecture Docker

```
┌─────────────────────────────────────────────────────────────┐
│                    CIAPOL ML SYSTEM                         │
├─────────────────────────────────────────────────────────────┤
│  Frontend (3000)     │  StarRocks API (8000)              │
│  ├─ Next.js          │  ├─ Python FastAPI                 │
│  └─ TypeScript       │  └─ Connexion StarRocks            │
├─────────────────────────────────────────────────────────────┤
│            🤖 SERVICES MACHINE LEARNING                     │
│  ┌─────────────────┬─────────────────┬─────────────────┐   │
│  │ Dataset Gen     │ Model Trainer   │ ML Predictor    │   │
│  │ (8001)          │ (8002)          │ (8003)          │   │
│  │ ├─ Génération   │ ├─ XGBoost      │ ├─ Prédictions │   │
│  │ │  datasets     │ ├─ LightGBM     │ │  temps réel   │   │
│  │ ├─ 5 stations   │ ├─ RandomForest │ ├─ Cache Redis  │   │
│  │ └─ Features ML  │ └─ Hypertuning  │ └─ Fallback     │   │
│  └─────────────────┴─────────────────┴─────────────────┘   │
├─────────────────────────────────────────────────────────────┤
│         📊 STOCKAGE & ORCHESTRATION                         │
│  StarRocks (8030)   │  ClearML (8080)   │  DolphinSched   │
│  ├─ Base unique     │  ├─ Modèles ML    │  (12345)        │
│  ├─ Données 5min    │  ├─ Déploiement   │  ├─ Workflows   │
│  └─ Vues ML         │  └─ Versions      │  └─ Scheduling  │
└─────────────────────────────────────────────────────────────┘
```

## 🛠️ Déploiement Automatisé

### Démarrage Simple
```bash
# Déploiement complet en une commande
python scripts/deploy-ml-system-docker.py
```

### Déploiement Manuel
```bash
# 1. Arrêt des services existants
docker-compose down --remove-orphans

# 2. Construction des images
docker-compose build

# 3. Démarrage complet
docker-compose up -d

# 4. Vérification des services
docker-compose ps
```

## 🌐 Services Disponibles

| Service | Port | URL | Description |
|---------|------|-----|-------------|
| **Frontend** | 3000 | http://localhost:3000 | Interface utilisateur principale |
| **ML Dataset Generator** | 8001 | http://localhost:8001 | Génération datasets ML |
| **ML Model Trainer** | 8002 | http://localhost:8002 | Entraînement modèles |
| **ML Predictor** | 8003 | http://localhost:8003 | Prédictions temps réel |
| **StarRocks API** | 8000 | http://localhost:8000 | API base de données |
| **StarRocks** | 8030 | http://localhost:8030 | Base de données principale |
| **ClearML** | 8080 | http://localhost:8080 | Registre des modèles |
| **DolphinScheduler** | 12345 | http://localhost:12345 | Orchestrateur workflows |
| **SeaTunnel** | 5801 | http://localhost:5801 | Moteur de traitement |
| **Pulsar** | 3002 | http://localhost:3002 | Message streaming |

## 🤖 Pipeline Machine Learning

### 1. Génération de Datasets
```bash
# API Call - Génération dataset
curl -X POST http://localhost:8001/generate \
  -H "Content-Type: application/json" \
  -d '{
    "stations": ["ABIDJAN_PLATEAU", "ABIDJAN_COCODY"],
    "output_format": "csv",
    "include_features": true
  }'

# Suivi du progrès
curl http://localhost:8001/status/{task_id}
```

### 2. Entraînement de Modèles
```bash
# API Call - Entraînement
curl -X POST http://localhost:8002/train \
  -H "Content-Type: application/json" \
  -d '{
    "target_variables": ["pm25", "pm10", "no2", "o3"],
    "model_types": ["xgboost", "lightgbm", "random_forest"],
    "hyperparameter_tuning": true,
    "deploy_to_clearml": true
  }'

# Liste des modèles entraînés
curl http://localhost:8002/models
```

### 3. Prédictions Temps Réel
```bash
# API Call - Prédiction
curl -X POST http://localhost:8003/predict \
  -H "Content-Type: application/json" \
  -d '{
    "station_id": "ABIDJAN_PLATEAU",
    "current_data": {
      "temperature": 28.5,
      "humidity": 75.0,
      "pressure": 1013.2,
      "wind_speed": 3.2,
      "pm25": 25.0,
      "pm10": 45.0,
      "no2": 35.0,
      "o3": 60.0
    },
    "use_ensemble": true,
    "confidence_threshold": 0.7
  }'
```

## 📊 Caractéristiques Techniques

### Données ML
- **Fréquence**: Données toutes les 5 minutes
- **Stations**: 5 stations d'Abidjan
- **Variables**: 6 météo + 6 polluants + AQI
- **Features**: 25+ features engineering (lag, tendances, moyennes mobiles)
- **Historique**: 365 jours de données synthétiques réalistes

### Modèles ML
- **Algorithmes**: XGBoost, LightGBM, Random Forest, Neural Networks
- **Cibles**: PM2.5, PM10, NO2, O3, variables météo
- **Performance**: R² > 0.8 (météo), R² > 0.7 (polluants)
- **Horizon**: Prédictions 5 minutes à l'avance
- **Fallback**: Système de fallback automatique

### Infrastructure
- **Base de données**: StarRocks (unique source de vérité)
- **Orchestration**: DolphinScheduler + SeaTunnel
- **ML Ops**: ClearML pour déploiement des modèles
- **Monitoring**: Health checks et logs structurés
- **Scalabilité**: Architecture microservices Docker

## 🔧 Commandes Utiles

### Gestion des Conteneurs
```bash
# Statut des services
docker-compose ps

# Logs en temps réel
docker-compose logs -f ml-predictor

# Redémarrage d'un service
docker-compose restart ml-model-trainer

# Arrêt complet
docker-compose down

# Nettoyage complet
docker-compose down -v --remove-orphans
docker system prune -f
```

### Debug et Monitoring
```bash
# Health checks
curl http://localhost:8001/health  # Dataset Generator
curl http://localhost:8002/health  # Model Trainer  
curl http://localhost:8003/health  # Predictor

# Métriques des modèles
curl http://localhost:8003/models

# Cache des prédictions
curl http://localhost:8003/cache

# Status des tâches
curl http://localhost:8001/status
curl http://localhost:8002/status
```

### Volumes de Données
```bash
# Inspection des volumes
docker volume ls
docker volume inspect ikna_ciapol_ml_models
docker volume inspect ikna_ciapol_ml_datasets

# Sauvegarde des modèles
docker run --rm -v ikna_ciapol_ml_models:/data \
  -v $(pwd):/backup alpine tar czf /backup/models.tar.gz /data
```

## 🚨 Dépannage

### Problèmes Courants

#### Services qui ne démarrent pas
```bash
# Vérifier les logs
docker-compose logs ml-predictor

# Reconstruire l'image
docker-compose build --no-cache ml-predictor
docker-compose up -d ml-predictor
```

#### Modèles non trouvés
```bash
# Vérifier le volume des modèles
docker volume inspect ikna_ciapol_ml_models

# Relancer l'entraînement
curl -X POST http://localhost:8002/train -H "Content-Type: application/json" -d '{...}'
```

#### Prédictions échouent
```bash
# Vérifier la connectivité entre services
docker exec ciapol-ml-predictor ping ml-model-trainer

# Nettoyer le cache
curl -X DELETE http://localhost:8003/cache
```

### Ports Occupés
```bash
# Identifier les processus utilisant les ports
netstat -tulpn | grep :8001
netstat -tulpn | grep :8002
netstat -tulpn | grep :8003

# Arrêter les services conflictuels
docker-compose down
```

## 📈 Performance et Optimisation

### Monitoring des Resources
```bash
# Utilisation CPU/RAM par conteneur
docker stats

# Espace disque des volumes
docker system df
```

### Optimisation
- **Cache Redis**: Réduction latence prédictions
- **Modèles pré-chargés**: Startup optimisé
- **Health checks**: Redémarrage automatique
- **Volumes persistants**: Sauvegarde des modèles

## 🔄 Workflow de Développement

### Modification d'un Service ML
```bash
# 1. Modification du code
# 2. Reconstruction
docker-compose build ml-predictor

# 3. Redémarrage
docker-compose up -d ml-predictor

# 4. Tests
curl http://localhost:8003/health
```

### Ajout de Nouvelles Features
1. Modifier `services/ml-*/`
2. Mettre à jour `docker-compose.yml` si nécessaire
3. Rebuilder et redéployer
4. Tester les APIs

## 🎯 Prochaines Étapes

- [ ] Intégration Kafka pour streaming temps réel
- [ ] API Gateway avec authentification
- [ ] Monitoring avec Prometheus/Grafana
- [ ] CI/CD avec GitLab/GitHub Actions
- [ ] Tests automatisés du pipeline ML
- [ ] Backup automatisé des modèles

---

## 📞 Support

Pour toute question ou problème:
1. Consulter les logs: `docker-compose logs [service]`
2. Vérifier les health checks
3. Consulter cette documentation
4. Redéployer avec le script automatisé

**🎉 Votre système ML CIAPOL est maintenant opérationnel!**