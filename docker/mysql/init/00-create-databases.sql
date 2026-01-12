-- ================================================
-- op-stack Database Initialization Script
-- Creates all required databases for the platform
-- ================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- Create databases
CREATE DATABASE IF NOT EXISTS op_stack_service CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS op_stack_auth CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS op_stack_executor CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS op_stack_tools CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges (for root user already has all privileges)
FLUSH PRIVILEGES;

SELECT 'All databases created successfully!' AS status;
