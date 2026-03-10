-- ============================================
-- CITYMATE - CITY DB Initialization Script
-- ============================================
-- Ce script crée les tables pour CITY API
-- Tables : pois (Points d'Intérêt), poi_reviews, events, 
--          event_registrations, deals, deal_saves
-- ============================================

-- Activation des extensions nécessaires
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS postgis;

-- ============================================
-- TABLE : POIS (Points d'Intérêt)
-- ============================================
CREATE TABLE IF NOT EXISTS pois (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) DEFAULT 'Brest',
    postal_code VARCHAR(10),
    phone_number VARCHAR(20),
    email VARCHAR(255),
    website_url TEXT,
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    opening_hours JSONB,
    is_verified BOOLEAN DEFAULT FALSE,
    created_by INTEGER,
    average_rating DECIMAL(3,2) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index spatial pour les recherches géographiques
CREATE INDEX idx_pois_location ON pois USING GIST(location);
CREATE INDEX idx_pois_category ON pois(category);
CREATE INDEX idx_pois_city ON pois(city);

-- Insertion de quelques POIs d'exemple pour Brest
INSERT INTO pois (name, description, category, address, city, postal_code, location, opening_hours) VALUES
('Mairie de Brest', 'Hôtel de ville - Services administratifs', 'Administration', '2 Rue Frézier', 'Brest', '29200', ST_SetSRID(ST_MakePoint(-4.486076, 48.390394), 4326)::geography, '{"lundi": "08:30-17:00", "mardi": "08:30-17:00", "mercredi": "08:30-17:00", "jeudi": "08:30-17:00", "vendredi": "08:30-17:00"}'),
('Gare SNCF de Brest', 'Gare ferroviaire principale', 'Transport', 'Place du 19e Régiment d''Infanterie', 'Brest', '29200', ST_SetSRID(ST_MakePoint(-4.476427, 48.389137), 4326)::geography, '{"tous": "05:00-23:00"}'),
('CHU de Brest - Hôpital La Cavale Blanche', 'Centre Hospitalier Universitaire', 'Santé', 'Boulevard Tanguy Prigent', 'Brest', '29200', ST_SetSRID(ST_MakePoint(-4.430395, 48.400883), 4326)::geography, '{"tous": "00:00-23:59"}'),
('Université de Bretagne Occidentale', 'Campus universitaire principal', 'Éducation', '3 Rue des Archives', 'Brest', '29200', ST_SetSRID(ST_MakePoint(-4.473513, 48.401291), 4326)::geography, '{"lundi": "08:00-18:00", "mardi": "08:00-18:00", "mercredi": "08:00-18:00", "jeudi": "08:00-18:00", "vendredi": "08:00-18:00"}')
ON CONFLICT DO NOTHING;

-- ============================================
-- TABLE : POI_REVIEWS (Avis sur les POIs)
-- ============================================
CREATE TABLE IF NOT EXISTS poi_reviews (
    id SERIAL PRIMARY KEY,
    poi_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (poi_id) REFERENCES pois(id) ON DELETE CASCADE
);

CREATE INDEX idx_poi_reviews_poi_id ON poi_reviews(poi_id);
CREATE INDEX idx_poi_reviews_user_id ON poi_reviews(user_id);

-- ============================================
-- TABLE : EVENTS (Événements)
-- ============================================
CREATE TABLE IF NOT EXISTS events (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL,
    location GEOGRAPHY(POINT, 4326),
    address TEXT,
    city VARCHAR(100) DEFAULT 'Brest',
    organizer VARCHAR(255),
    max_participants INTEGER,
    current_participants INTEGER DEFAULT 0,
    price DECIMAL(10,2) DEFAULT 0.0,
    is_free BOOLEAN DEFAULT TRUE,
    image_url TEXT,
    registration_deadline TIMESTAMP,
    is_published BOOLEAN DEFAULT TRUE,
    created_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_events_start_date ON events(start_date);
CREATE INDEX idx_events_category ON events(category);
CREATE INDEX idx_events_city ON events(city);
CREATE INDEX idx_events_location ON events USING GIST(location);

-- ============================================
-- TABLE : EVENT_REGISTRATIONS (Inscriptions aux événements)
-- ============================================
CREATE TABLE IF NOT EXISTS event_registrations (
    id SERIAL PRIMARY KEY,
    event_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'CONFIRMED' CHECK (status IN ('CONFIRMED', 'CANCELLED', 'WAITING_LIST')),
    UNIQUE(event_id, user_id),
    FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE
);

CREATE INDEX idx_event_registrations_event_id ON event_registrations(event_id);
CREATE INDEX idx_event_registrations_user_id ON event_registrations(user_id);

-- ============================================
-- TABLE : DEALS (Bons plans)
-- ============================================
CREATE TABLE IF NOT EXISTS deals (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    discount_percentage INTEGER,
    original_price DECIMAL(10,2),
    discounted_price DECIMAL(10,2),
    merchant_name VARCHAR(255),
    address TEXT,
    city VARCHAR(100) DEFAULT 'Brest',
    location GEOGRAPHY(POINT, 4326),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    terms_conditions TEXT,
    promo_code VARCHAR(50),
    website_url TEXT,
    image_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    total_saves INTEGER DEFAULT 0,
    total_uses INTEGER DEFAULT 0,
    created_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_deals_category ON deals(category);
CREATE INDEX idx_deals_end_date ON deals(end_date);
CREATE INDEX idx_deals_is_active ON deals(is_active);
CREATE INDEX idx_deals_location ON deals USING GIST(location);

-- ============================================
-- TABLE : DEAL_SAVES (Bons plans sauvegardés)
-- ============================================
CREATE TABLE IF NOT EXISTS deal_saves (
    id SERIAL PRIMARY KEY,
    deal_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP,
    UNIQUE(deal_id, user_id),
    FOREIGN KEY (deal_id) REFERENCES deals(id) ON DELETE CASCADE
);

CREATE INDEX idx_deal_saves_deal_id ON deal_saves(deal_id);
CREATE INDEX idx_deal_saves_user_id ON deal_saves(user_id);

-- ============================================
-- Script terminé avec succès
-- ============================================
-- Tables créées : pois, poi_reviews, events, 
--                 event_registrations, deals, deal_saves
-- Extension PostGIS activée pour la géolocalisation
