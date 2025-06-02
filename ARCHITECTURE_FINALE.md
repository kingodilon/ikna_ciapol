# Architecture Finale CIAPOL - StarRocks Unique

## 🎯 PRINCIPE FONDAMENTAL

**StarRocks est la SEULE et UNIQUE base de données de stockage des données CIAPOL.**

**Toutes les données de l'interface utilisateur proviennent EXCLUSIVEMENT de l'API interne de StarRocks.**

## 📊 Architecture Pure StarRocks

```
┌─────────────────────────────────────────────────────────────┐
│                    CIAPOL DATA FLOW                        │
└─────────────────────────────────────────────────────────────┘

Capteurs IoT
    ↓
SeaTunnel Zeta Engine ────→ Pulsar ────→ StarRocks (SEULE DB)
    ↓                                         ↑
DolphinScheduler                             │
(orchestration)                              │
    ↓                                        │
PostgreSQL                                   │
(métadonnées DS uniquement)                 │
                                            │
Frontend ←─── StarRocks API ←───────────────┘
(100% données StarRocks)
```

## 🏗️ Composants et Rôles

### ✅ StarRocks - Base de Données Unique
- **Rôle** : SEULE source de données CIAPOL
- **Stockage** : 
  - Données en temps réel
  - Données historiques  
  - Agrégations AQI
  - Archives long terme
  - Prédictions ML
- **API** : MySQL protocol (port 9030)
- **Interface** : Web UI (port 8030)

### ✅ SeaTunnel Zeta Engine - Traitement Temps Réel
- **Rôle** : Ingestion et transformation vers StarRocks uniquement
- **Source** : Capteurs IoT via Pulsar
- **Destination** : StarRocks exclusivement
- **Engine** : Zeta Engine haute performance

### ✅ DolphinScheduler - Orchestration
- **Rôle** : Orchestration des workflows SeaTunnel
- **Données** : Métadonnées dans PostgreSQL séparé
- **Jobs** : Pilotage des tâches Zeta Engine

### ✅ PostgreSQL - Métadonnées Techniques
- **Rôle** : UNIQUEMENT métadonnées DolphinScheduler
- **Contenu** : Workflows, schedules, logs système
- **⚠️ AUCUNE donnée applicative CIAPOL**

### ✅ Frontend - Interface Pure StarRocks
- **Source de données** : 100% StarRocks via API
- **Aucune autre base** : Pas d'accès PostgreSQL
- **Connexions** : StarRocks API (port 8000) et direct (port 9030)

## ❌ Composants Supprimés Définitivement

### 🗑️ MinIO
- **Supprimé** : Stockage objet S3 
- **Remplacé par** : StarRocks natif

### 🗑️ Iceberg
- **Supprimé** : Format table data lake
- **Remplacé par** : Tables StarRocks

### 🗑️ Paimon
- **Supprimé** : Lakehouse Apache
- **Remplacé par** : Tables StarRocks

### 🗑️ Dremio
- **Supprimé** : Moteur de requête
- **Remplacé par** : StarRocks natif

## 📋 Tables StarRocks - Stockage Unique

### Tables Principales
1. **`sensor_measurements_zeta`** - Données temps réel
2. **`aqi_hourly_zeta`** - Agrégations horaires  
3. **`raw_measurements_zeta`** - Données brutes
4. **`sensor_measurements_archive_zeta`** - Archives

### Caractéristiques Techniques
- **Partitioning** : Temporal par mois
- **Distribution** : Hash sur `station_id`
- **Compression** : LZ4
- **Index** : Persistants activés
- **Vues matérialisées** : Pour requêtes fréquentes

## 🔄 Flux de Données Unique

### Ingestion Temps Réel
```
IoT Sensors → Pulsar → SeaTunnel Zeta → StarRocks
```

### Traitement Analytics
```
StarRocks → SeaTunnel Zeta → StarRocks (tables agrégées)
```

### Interface Utilisateur
```
Frontend → StarRocks API → StarRocks → Données affichées
```

### Machine Learning
```
StarRocks → ML Predictor → StarRocks (prédictions)
```

## 🛡️ Garanties de Données

### Source Unique de Vérité
- **StarRocks** = Seule base de données
- **Cohérence** = Pas de synchronisation multi-bases
- **Performance** = Accès direct haute vitesse

### Exactly-Once Processing
- **SeaTunnel Zeta** = Garanties exactly-once
- **StarRocks ACID** = Transactions complètes
- **Pas de doublons** = Clés primaires contraintes

### Haute Disponibilité
- **StarRocks cluster** = Réplication automatique
- **Checkpointing Zeta** = Reprise sur erreur
- **Monitoring** = Métriques temps réel

## 🚀 Avantages Architecture Unique

### Simplicité
- **1 seule base** au lieu de 4+ composants
- **API unique** StarRocks
- **Maintenance** simplifiée

### Performance
- **Accès direct** sans middleware
- **Zeta Engine** optimisé
- **StarRocks** analytics haute vitesse

### Cohérence
- **Source unique** de vérité
- **Pas de sync** entre bases
- **Transactions** complètes

### Coût
- **Moins de ressources** serveur
- **Moins de complexité** opérationnelle
- **Formation** réduite équipes

## 📈 Monitoring et Métriques

### StarRocks Métriques
```sql
-- Utilisation tables
SELECT TABLE_NAME, TABLE_ROWS, DATA_LENGTH 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'ciapol_analytics';

-- Performance requêtes
SHOW PROCESSLIST;
```

### SeaTunnel Zeta Métriques
```bash
# Métriques Prometheus
curl http://localhost:9090/metrics | grep seatunnel_zeta
```

### Application Monitoring
```bash
# Vérification API StarRocks
curl http://localhost:8000/health

# Frontend status
curl http://localhost:3000/api/status
```

## 🎯 URLs d'Accès

### Interfaces Principales
- **StarRocks Web UI** : http://localhost:8030
- **Frontend CIAPOL** : http://localhost:3000
- **StarRocks API** : http://localhost:8000
- **DolphinScheduler** : http://localhost:12345

### APIs Techniques  
- **StarRocks MySQL** : mysql://localhost:9030
- **Pulsar Admin** : http://localhost:8080
- **SeaTunnel Zeta** : localhost:5801

## ⚡ Commandes de Déploiement

### Déploiement Complet
```bash
cd ikna_ciapol
./scripts/deploy-zeta-starrocks.sh
```

### Vérification StarRocks
```bash
mysql -h127.0.0.1 -P9030 -uroot -e "SHOW DATABASES;"
```

### Test Pipeline
```bash
docker-compose logs -f seatunnel
```

---

**🎯 RÉSUMÉ : StarRocks est la SEULE base de données. Toutes les données de l'interface proviennent exclusivement de StarRocks via son API interne.**