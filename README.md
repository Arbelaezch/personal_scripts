# Zsh Scripts

A collection of zsh scripts I spent hours building to save me whole minutes of time.

No promises that these will work for either your environment or personal sensibilities.

## create_django_project.zsh

Creates a local Django project with your given name and MySQL database details.

Actions executed by the script:

- Creates and initializes a virtual environment, env/

- Creates a basic base.html in templates/, and includes it in settings.py

- Creates empty style.css and script.js in BASE_DIR/static/ and adds them to settings.py

- Adds MySQL database configuration to settings.py, removes SQLite

- Creates a basic .gitignore file

- Creates and adds database config details to .env file

- Creates a local MySQL database with the given name
