-- ============================================
-- CITYMATE - USER DB Initialization Script
-- ============================================
-- Ce script crée les tables pour USER API
-- Tables : users, roles, user_roles, checklist_templates, 
--          user_checklist_items, user_interests
-- ============================================

-- Activation des extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE : ROLES
-- ============================================
CREATE TABLE IF NOT EXISTS roles (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion des rôles par défaut
INSERT INTO roles (name, description) VALUES
('VISITOR', 'Utilisateur non inscrit avec accès limité'),
('CLIENT', 'Utilisateur inscrit standard'),
('ADMIN', 'Administrateur avec tous les droits'),
('STUDENT', 'Étudiant inscrit sur CityMate')
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- TABLE : USERS
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    profile_picture_url TEXT,
    bio TEXT,
    city VARCHAR(100),
    phone_number VARCHAR(20),
    date_of_birth DATE,
    profile_type VARCHAR(20) CHECK (profile_type IN ('STUDENT', 'EMPLOYEE', 'OTHER')),
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_is_active ON users(is_active);

-- ============================================
-- TABLE : USER_ROLES (Table de liaison)
-- ============================================
CREATE TABLE IF NOT EXISTS user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
);

-- ============================================
-- TABLE : USER_INTERESTS
-- ============================================
CREATE TABLE IF NOT EXISTS user_interests (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    interest VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_interests_user_id ON user_interests(user_id);

-- ============================================
-- TABLE : CHECKLIST_TEMPLATES
-- ============================================
CREATE TABLE IF NOT EXISTS checklist_templates (
    id SERIAL PRIMARY KEY,
    category VARCHAR(100) NOT NULL,
    task_name VARCHAR(255) NOT NULL,
    description TEXT,
    profile_type VARCHAR(20) CHECK (profile_type IN ('STUDENT', 'EMPLOYEE', 'BOTH')),
    priority INTEGER DEFAULT 0,
    estimated_days INTEGER,
    is_mandatory BOOLEAN DEFAULT FALSE,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion de quelques tâches par défaut
INSERT INTO checklist_templates (category, task_name, description, profile_type, priority, estimated_days, is_mandatory, order_index) VALUES
('Administratif', 'Ouvrir un compte bancaire', 'Ouvrir un compte bancaire local pour faciliter les transactions', 'BOTH', 1, 3, TRUE, 1),
('Administratif', 'Inscription à la CAF', 'S''inscrire à la Caisse d''Allocations Familiales pour les aides au logement', 'STUDENT', 1, 7, TRUE, 2),
('Logement', 'Souscrire à une assurance habitation', 'Assurer son logement contre les risques', 'BOTH', 1, 2, TRUE, 3),
('Transport', 'Acheter une carte de transport', 'Obtenir un abonnement mensuel pour les transports en commun', 'BOTH', 2, 1, FALSE, 4),
('Santé', 'Trouver un médecin traitant', 'Déclarer un médecin traitant auprès de l''Assurance Maladie', 'BOTH', 2, 14, FALSE, 5),
('Administratif', 'Inscription à Pôle Emploi', 'S''inscrire comme demandeur d''emploi si nécessaire', 'EMPLOYEE', 1, 3, FALSE, 6),
('Études', 'Inscription à l''université', 'Finaliser l''inscription administrative à l''université', 'STUDENT', 1, 7, TRUE, 7),
('Études', 'Obtenir la carte étudiante', 'Récupérer la carte étudiante pour les réductions', 'STUDENT', 2, 7, FALSE, 8)
ON CONFLICT DO NOTHING;

-- ============================================
-- TABLE : USER_CHECKLIST_ITEMS
-- ============================================
CREATE TABLE IF NOT EXISTS user_checklist_items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    template_id INTEGER,
    task_name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    deadline DATE,
    priority INTEGER DEFAULT 0,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (template_id) REFERENCES checklist_templates(id) ON DELETE SET NULL
);

CREATE INDEX idx_user_checklist_user_id ON user_checklist_items(user_id);
CREATE INDEX idx_user_checklist_completed ON user_checklist_items(is_completed);

-- ============================================
-- Script terminé avec succès
-- ============================================
-- Tables créées : roles, users, user_roles, user_interests, 
--                 checklist_templates, user_checklist_items
