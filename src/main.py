from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from . import smokeTest  # <- relative import

import debugpy

debugpy.listen(("0.0.0.0", 5678))
# debugpy.wait_for_client()

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(smokeTest.router, prefix="/smoke-test")

@app.get("/")
def health():
    return {"message": "OK 🚀"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
