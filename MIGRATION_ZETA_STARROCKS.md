# Migration CIAPOL vers SeaTunnel Zeta Engine + StarRocks

## 🎯 Objectif de la Migration

Cette migration **SUPPRIME COMPLÈTEMENT** MinIO, Iceberg, Paimon et Dremio du système et remplace tout par **StarRocks** comme **SEULE** base de données de stockage. Tous les jobs SeaTunnel utilisent **Zeta Engine** avec orchestration complète par **DolphinScheduler**.

## ⚠️ SUPPRESSION COMPLÈTE DES ANCIENS COMPOSANTS

### ❌ Composants Supprimés Définitivement
- **MinIO** : Plus de stockage objet S3
- **Iceberg** : Plus de format de table data lake
- **Paimon** : Plus de lakehouse Apache Paimon
- **Dremio** : Plus de moteur de requête séparé

### ✅ StarRocks = SEULE Base de Données
StarRocks remplace **TOUS** les systèmes de stockage et devient la source unique de vérité pour :
- Données en temps réel
- Données historiques
- Analytics et requêtes
- Archivage long terme

## 📋 Résumé des Changements

### ✅ Modifications Effectuées

#### 1. Jobs SeaTunnel Mis à Jour
- **`sensor-data-generator.conf`** : Migration vers Zeta Engine + StarRocks
- **`aqi-calculator.conf`** : Migration vers Zeta Engine + StarRocks  
- **`sensor-data-zeta.conf`** : Remplacement sink Iceberg par StarRocks

#### 2. Configuration Zeta Engine
Tous les jobs utilisent maintenant :
```yaml
env {
  execution.parallelism = 4
  execution.checkpoint.interval = 30000
  execution.checkpoint.mode = "EXACTLY_ONCE"
  zeta.checkpoint.compression = true
  zeta.adaptive-scheduling = true
  zeta.dynamic-slot-allocation = true
}
```

#### 3. Tables StarRocks Créées
- **`sensor_measurements_zeta`** : Données en temps réel (remplace Iceberg)
- **`aqi_hourly_zeta`** : AQI agrégés horaires (remplace Paimon)
- **`raw_measurements_zeta`** : Données brutes (remplace Paimon)
- **`sensor_measurements_archive_zeta`** : Archivage long terme (remplace Iceberg)

#### 4. Orchestration DolphinScheduler
Nouveau workflow **`seatunnel-zeta-pipeline.json`** qui orchestre :
1. Génération des données capteurs (Zeta Engine)
2. Calcul AQI (Zeta Engine)
3. Streaming enrichi (Zeta Engine)
4. Validation données StarRocks
5. Optimisation StarRocks
6. Nettoyage logs

## 🚀 Déploiement

### Prérequis
- Docker et Docker Compose installés
- StarRocks accessible sur le port 9030
- DolphinScheduler accessible sur le port 12345

### Étapes de Déploiement

1. **Exécuter le script de migration** :
```bash
cd ikna_ciapol
./scripts/deploy-zeta-starrocks.sh
```

2. **Le script effectue automatiquement** :
   - Arrêt des anciens services
   - Démarrage StarRocks + SeaTunnel + DolphinScheduler
   - Initialisation des tables StarRocks
   - Déploiement du workflow DolphinScheduler
   - Tests de validation des jobs

3. **Vérification post-déploiement** :
   - Accéder à DolphinScheduler : http://localhost:12345
   - Activer le workflow `CIAPOL_SeaTunnel_Zeta_Pipeline`
   - Vérifier les données dans StarRocks : http://localhost:9030

## 📊 Architecture Avant/Après

### ❌ Avant (Iceberg/Paimon)
```
SeaTunnel (ancien engine) → Pulsar → Iceberg/Paimon → MinIO
                                   ↘ Dremio (requêtes)
```

### ✅ Après (Zeta Engine + StarRocks)
```
SeaTunnel (Zeta Engine) → Pulsar → StarRocks (analytics haute performance)
                       ↘ StarRocks (direct) ↗
DolphinScheduler (orchestration complète)
```

## 🔧 Configuration Technique

### Jobs SeaTunnel Zeta Engine

#### Générateur de Données
- **Fichier** : `services/seatunnel/jobs/sensor-data-generator.conf`
- **Engine** : Zeta Engine
- **Sink** : StarRocks JDBC (`raw_measurements_zeta`)
- **Parallélisme** : 4 threads
- **Checkpoint** : 30 secondes

#### Calculateur AQI
- **Fichier** : `services/seatunnel/jobs/aqi-calculator.conf`
- **Engine** : Zeta Engine
- **Source** : Pulsar (données capteurs)
- **Sink** : StarRocks JDBC (`aqi_hourly_zeta`)
- **Fenêtrage** : 1 heure glissante

#### Streaming Enrichi
- **Fichier** : `services/seatunnel/jobs/sensor-data-zeta.conf`
- **Engine** : Zeta Engine
- **Sources** : FakeSource (simulation)
- **Sinks** : Pulsar + StarRocks (`sensor_measurements_zeta` + `sensor_measurements_archive_zeta`)

### Tables StarRocks

#### Partitioning Temporel
Toutes les tables utilisent un partitioning mensuel :
```sql
PARTITION BY RANGE(processing_time) (
    PARTITION p20250101 VALUES [('2025-01-01'), ('2025-02-01')),
    PARTITION p20250201 VALUES [('2025-02-01'), ('2025-03-01')),
    -- ...
)
```

#### Optimisations
- **Compression** : LZ4
- **Distribution** : HASH sur `station_id`
- **Index persistants** activés
- **Vues matérialisées** pour requêtes fréquentes

### Orchestration DolphinScheduler

#### Workflow Principal
**Nom** : `CIAPOL_SeaTunnel_Zeta_Pipeline`
**Fréquence** : Toutes les heures (cron: `0 */1 * * *`)

#### Tâches Séquentielles
1. **SeaTunnel Sensor Generator Zeta** (900s timeout)
2. **SeaTunnel AQI Calculator Zeta** (1200s timeout)
3. **SeaTunnel Sensor Data Zeta Stream** (1500s timeout)
4. **Validation Données StarRocks** (300s timeout)
5. **Optimisation StarRocks** (600s timeout)
6. **Nettoyage Logs** (300s timeout)

## 📈 Avantages de la Migration

### Performance
- **Zeta Engine** : Meilleure performance que l'ancien moteur SeaTunnel
- **StarRocks** : Analytics haute performance vs format fichier Iceberg/Paimon
- **Exactly-Once Processing** : Garanties de cohérence renforcées

### Simplicité
- **Architecture Unifiée** : Une seule base de données (StarRocks) vs multiples formats
- **Requêtes SQL Standard** : Compatible MySQL vs APIs spécialisées
- **Maintenance Réduite** : Moins de composants à gérer

### Scalabilité
- **Partitioning Automatique** : StarRocks gère automatiquement les partitions
- **Compression Avancée** : Meilleur ratio compression/performance
- **Parallélisme Optimisé** : Zeta Engine adapte automatiquement le parallélisme

## 🔍 Surveillance et Monitoring

### Métriques Zeta Engine
```bash
# Via Prometheus (port 9090)
curl http://localhost:9090/metrics | grep seatunnel_zeta
```

### Métriques StarRocks
```sql
-- Utilisation des tables
SELECT TABLE_NAME, TABLE_ROWS, DATA_LENGTH 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'ciapol_analytics' AND TABLE_NAME LIKE '%_zeta';

-- Performance des requêtes
SELECT * FROM information_schema.loads ORDER BY create_time DESC LIMIT 10;
```

### Logs DolphinScheduler
```bash
# Logs du workflow Zeta
docker logs $(docker ps -q -f name=dolphinscheduler) | grep "CIAPOL_SeaTunnel_Zeta"
```

## 🛠️ Dépannage

### Problèmes Courants

#### 1. Zeta Engine ne démarre pas
```bash
# Vérifier la configuration Hazelcast
docker exec -it seatunnel cat /opt/seatunnel/config/hazelcast-zeta.yaml
```

#### 2. Connexion StarRocks échoue
```bash
# Test connectivité
docker exec -it starrocks mysql -h127.0.0.1 -P9030 -uroot -e "SHOW DATABASES;"
```

#### 3. Jobs SeaTunnel en erreur
```bash
# Logs détaillés
docker exec -it seatunnel tail -f /opt/seatunnel/logs/seatunnel-engine.log
```

#### 4. Workflow DolphinScheduler bloqué
```bash
# Redémarrer DolphinScheduler
docker-compose restart dolphinscheduler
```

## 📚 Documentation Complémentaire

- **SeaTunnel Zeta Engine** : [Documentation officielle](https://seatunnel.apache.org/docs/2.3.x/engine/zeta-engine)
- **StarRocks** : [Documentation StarRocks](https://docs.starrocks.io/)
- **DolphinScheduler** : [Guide d'orchestration](https://dolphinscheduler.apache.org/docs/latest)

## 🎯 Prochaines Étapes

1. **Monitoring Avancé** : Configurer Grafana avec métriques Zeta Engine + StarRocks
2. **Optimisation Requêtes** : Créer des index supplémentaires selon les patterns d'usage
3. **Alerting** : Configurer alertes sur échec des jobs Zeta Engine
4. **Backup** : Mettre en place stratégie de sauvegarde StarRocks
5. **Scaling** : Étudier l'ajout de nœuds StarRocks pour la montée en charge

---

**Date de Migration** : 2025-06-02  
**Version** : CIAPOL 2.0 (Zeta Engine + StarRocks)  
**Statut** : ✅ Migration Terminée