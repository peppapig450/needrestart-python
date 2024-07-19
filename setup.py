from setuptools import setup, Extension
from Cython.Build import cythonize

extensions = [
    Extension(
        "systemd_services",
        sources=["systemd_services/systemd_services.pyx"],
        libraries=["systemd"],
        include_dirs=["/usr/include"],
        library_dirs=["/usr/lib"],
    )
]

setup(name="systemd_services", ext_modules=cythonize(extensions))
