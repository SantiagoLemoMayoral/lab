# app.py

from fastapi import FastAPI, HTTPException
import random
import time

app = FastAPI()


@app.get("/")
def root():
    return {"service": "lab-api", "status": "running"}


# Very cheap endpoint.
# Kubernetes probes can use this.
@app.get("/health")
def health():
    return {"status": "healthy"}


# CPU-intensive endpoint.
# Useful for triggering HPA CPU scaling.
@app.get("/work")
def work(ms: int = 100):
    end = time.perf_counter() + (ms / 1000)

    x = 0
    while time.perf_counter() < end:
        x = (x * 13 + 7) % 1000003

    return {
        "status": "completed",
        "work_ms": ms,
    }


# Artificial latency without heavy CPU.
@app.get("/slow")
def slow(ms: int = 500):
    time.sleep(ms / 1000)

    return {
        "status": "completed",
        "delay_ms": ms,
    }


# Controlled failures.
@app.get("/error")
def error(rate: float = 0.2):
    if random.random() < rate:
        raise HTTPException(
            status_code=500,
            detail="Synthetic failure",
        )

    return {"status": "ok"}