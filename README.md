# Headcount-SQL-Data-Model

About

This repository contains the data model for an Oracle-based headcount report. The model is designed to provide accurate and historical headcount analysis by integrating data from various Oracle Human Capital Management (HCM) sources. This data model is best opened in either Notepad++ or a more advanced text and source code editor with SQL as the language.

Features

•	Time-Effective Headcount: The model supports date-effective analysis, allowing for accurate headcount reporting as of any specific date, rather than just the current date.

•	Dimensional Reporting: It provides a dimensional model for comprehensive reporting on headcount by various categories, such as department, job, location, and worker type.

•	SQL Scripts: Includes SQL scripts for creating the schema, loading data, and generating this common headcount report.

•	Data Integrity: The schema is designed to ensure synchronization of position, worker, and assignment data, providing reliable, consistent reporting.

Comments/Changes

This data model has been updated from its original out-of-the-box functionality. Examples of these changes are the gender coding (line 70), various changes made to prepare the reporting data model's company coding for a spin-off (lines 250 and 253), and various updates that stabilize the managerial hierarchy by insulating this data model from the recruiting model hierarchy (lines 314-336).

Skills Used

SQL: Data retrieval and filtering, Data aggregation and summarization, Joins, Subqueries, CTEs

Author

Ian Hood – github.com/Hood-Analytics
