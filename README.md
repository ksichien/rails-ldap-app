# Rails LDAP App (RLA)

This is a Ruby on Rails application for creating, modifying and deleting groups and users on an OpenLDAP server.
A user can log in with their LDAP mail address and password.
The application will perform all requested operations with the user's LDAP account.

This project is the final step in the process to simplify OpenLDAP user creation.
Since its creation, I've continuously expanded on it and it now encompasses most LDAP operations.

## Overview

The available operations are listed below:
- Add a user to multiple groups
- Add multiple users to a group
- Create a new group
- Create a new user
- Change a user's password
- Delete an existing group
- Delete an existing user
- Remove a user from multiple groups
- Remove multiple users from a group
- Search across the entire directory for a group or a user
- Search for all group memberships of a user

When the operation is executed, it will perform it on the OpenLDAP server and render a new page displaying the result.
