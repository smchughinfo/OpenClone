from setuptools import setup, find_packages

setup(
    name="LogWeaver",
    version="1.0.0",
    packages=find_packages(),
    url='https://github.com/smchughinfo/LogWeaver',
    install_requires=[
        'psycopg2-binary',   # Add specific version if needed, like 'psycopg2==2.9.1'
        'pytz'        # Add specific version if needed
    ],
    python_requires='>=3.8, <3.12'
)
