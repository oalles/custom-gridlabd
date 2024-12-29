#!/bin/bash

# Definir paths
MODEL_PATH="/simulation/models/model.glm"
LOGS_DIR="/simulation/outputs"
LOG_FILE="$LOGS_DIR/simulation.log"

# Crear estructura de directorios
mkdir -p "$LOGS_DIR"

# Función para registrar eventos
log_event() {
    local EVENT=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $EVENT" >> "$LOG_FILE"
}

# Evento: simulation_starting
log_event "simulation_starting"

if [ ! -f "$MODEL_PATH" ]; then
    log_event "simulation_failed - Model file not found at $MODEL_PATH"
    echo "Error: No se encontró el modelo en $MODEL_PATH." >> "$LOGS_DIR/errors.log"
    exit 1
fi

log_event "simulation_started"

# Ejecutar la simulación redireccionando todos los streams
if gridlabd \
    --output=JSON \
    --profile=CSV \
    --redirect output:"$LOGS_DIR/output.log" \
    --redirect error:"$LOGS_DIR/errors.log" \
    --redirect warning:"$LOGS_DIR/warnings.log" \
    --redirect debug:"$LOGS_DIR/debug.log" \
    --redirect verbose:"$LOGS_DIR/verbose.log" \
    --redirect profile:"$LOGS_DIR/profile.log" \
    --redirect progress:"$LOGS_DIR/progress.log" \
    "$MODEL_PATH" -o "$LOGS_DIR/results"; then
    log_event "simulation_ended - Simulation completed successfully"
else
    log_event "simulation_failed - Simulation encountered an error"
    exit 1
fi