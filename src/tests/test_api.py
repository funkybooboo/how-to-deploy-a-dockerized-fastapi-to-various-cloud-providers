"""Tests for API endpoints."""

import os

from fastapi.testclient import TestClient

# Set test environment before importing app
os.environ["ENVIRONMENT"] = "testing"
os.environ["DEBUG"] = "false"

from src.main import app

client = TestClient(app)


def test_root_endpoint():
    """Test root health check endpoint."""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert data["message"] == "OK 🚀"
    assert "environment" in data
    assert "version" in data


def test_health_endpoint():
    """Test health check endpoint."""
    response = client.get("/api/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert data["message"] == "OK"


def test_hello_endpoint():
    """Test hello world endpoint."""
    response = client.get("/api/hello")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Hello, World!"


def test_hello_name_endpoint():
    """Test personalized hello endpoint."""
    name = "Alice"
    response = client.get(f"/api/hello/{name}")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == f"Hello, {name}!"


def test_api_docs_accessible():
    """Test that API documentation is accessible."""
    response = client.get("/api/docs")
    assert response.status_code == 200


def test_redoc_accessible():
    """Test that ReDoc documentation is accessible."""
    response = client.get("/api/redoc")
    assert response.status_code == 200
