#!/bin/bash

# Deploy the application
git push scalingo master

# Run database migrations
scalingo run rails db:migrate