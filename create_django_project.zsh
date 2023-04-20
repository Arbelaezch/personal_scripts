#!/bin/zsh
set -e

# Get user input for project name, database name, user, and password
echo "Enter the project name:"
read PROJECT_NAME
echo "Enter the database name:"
read DB_NAME
echo "Enter the MySQL username:"
read DB_USER
echo "Enter the MySQL password:"
read DB_PASSWORD

SETTINGS_FILE="$PROJECT_NAME/$PROJECT_NAME/settings.py"

# Create project directory
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# Create and activate virtual environment, "env"
python3 -m venv env
source env/bin/activate

# Upgrade pip and install necessary packages
pip install --upgrade pip
pip install django python-dotenv mysqlclient
pip freeze > requirements.txt

# Create Django project
django-admin startproject $PROJECT_NAME

# Create Files and Directories
mkdir -p $PROJECT_NAME/templates
mkdir -p $PROJECT_NAME/static/css
mkdir -p $PROJECT_NAME/static/js
touch $PROJECT_NAME/templates/base.html
touch $PROJECT_NAME/static/css/style.css
touch $PROJECT_NAME/static/js/main.js


# Settings.py file changes

# Add 'BASE_DIR / 'templates'' to the 'DIRS': [] list in TEMPLATES variable
perl -i -pe "s/'DIRS': \[\],/'DIRS': [BASE_DIR \/ 'templates'],/g" $SETTINGS_FILE

# Add 'BASE_DIR / 'static'' to the STATICFILES_DIRS list.
echo 'STATICFILES_DIRS = [ BASE_DIR / "static", ]' >> "$SETTINGS_FILE"

# Comment out the default SQlite database configuration
perl -i -pe 's/(\s+'\''ENGINE'\'': '\''django.db.backends.sqlite3'\'',)/# $1\n        '\''ENGINE'\'': '\''django.db.backends.mysql'\'',/g; s/(\s+'\''NAME'\'': BASE_DIR \/ '\''db.sqlite3'\'',)/# $1\n        '\''NAME'\'': os.environ.get('\''DB_NAME'\''),\n        '\''USER'\'': os.environ.get('\''DB_USER'\''),\n        '\''PASSWORD'\'': os.environ.get('\''DB_PASSWORD'\''),\n        '\''HOST'\'': '\''localhost'\'',\n        '\''PORT'\'': '\''3306'\'',/g' "$SETTINGS_FILE"

# Add os and load_dotenv imports
perl -i -pe 's/(from pathlib import Path)/$1\nimport os\nfrom dotenv import load_dotenv\nload_dotenv()/g' "$SETTINGS_FILE"


# Create .gitignore
touch .gitignore
cat > .gitignore << EOL
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]

# Local development settings
.env
env/
/.venv/

# Media and static files
/media/
/static/

# Database files
*.db
*.sqlite3

# Logs
*.log
logs/

# Environment-specific files
*.env

# Other
*.swp
.DS_Store
EOL

# Create .env
touch .env
cat > .env << EOL
# Database
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
DB_HOST=localhost
DB_PORT=3306
EOL

# Add base.html template
echo '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{% block title %}{% endblock %}</title>
    <link rel="stylesheet" href="{% static '\''css/style.css'\'' %}">
    {% block extra_css %}{% endblock %}
</head>
<body>
    <nav>
        <ul>
            <li><a href="{% url '\''home'\'' %}">Home</a></li>
            <li><a href="{% url '\''about'\'' %}">About</a></li>
            <li><a href="{% url '\''contact'\'' %}">Contact</a></li>
        </ul>
    </nav>
    <div class="container">
        {% block content %}{% endblock %}
    </div>
    <script src="{% static '\''js/main.js'\'' %}"></script>
    {% block extra_js %}{% endblock %}
</body>
</html>' > "$PROJECT_NAME/templates/base.html"

# Create database
mysql -u$DB_USER -p$DB_PASSWORD -e "CREATE DATABASE $DB_NAME;"

# Run initial migrations
(cd $PROJECT_NAME && python manage.py migrate)

# Deactivate the virtual environment
deactivate

echo "Django project created successfully!"