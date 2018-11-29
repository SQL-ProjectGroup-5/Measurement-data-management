# Measurement-data-management
Messwert- und Stationsmanagementsystem
## Creating the database structure
In order to create the database for development the following scripts have to be executed in the exact same order as follows:
1. Create_tables.sql
2. all sql scripts beginning with tg_ or sp_ (triggers and stored procedures)
3. Demo_data.sql
4. Insert_real_measurements.sql