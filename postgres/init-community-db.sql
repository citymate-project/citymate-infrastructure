-- ============================================
-- CITYMATE - COMMUNITY DB Initialization Script correction pour sara
-- ============================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE : FORUM_CATEGORIES
-- ============================================
CREATE TABLE IF NOT EXISTS forum_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insertion des catégories par défaut
INSERT INTO forum_categories (name, slug, description, icon, order_index) VALUES
('Bienvenue', 'bienvenue', 'Présentez-vous et rencontrez la communauté', '👋', 1),
('Logement', 'logement', 'Trouvez des colocataires, partagez des bons plans logement', '🏠', 2),
('Vie étudiante', 'vie-etudiante', 'Discutez de vos études, partagez vos expériences', '📚', 3),
('Emploi', 'emploi', 'Offres d''emploi, stages, conseils carrière', '💼', 4),
('Sorties & Événements', 'sorties-evenements', 'Organisez des sorties, partagez des événements', '🎉', 5),
('Bons plans', 'bons-plans', 'Partagez vos bonnes adresses et astuces', '💡', 6),
('Questions pratiques', 'questions-pratiques', 'Toutes vos questions sur la vie à Brest', '❓', 7),
('Aide & Support', 'aide-support', 'Besoin d''aide ? Posez vos questions ici', '🆘', 8)
ON CONFLICT (name) DO NOTHING;

-- ============================================
-- TABLE : FORUM_DISCUSSIONS
-- ============================================
CREATE TABLE IF NOT EXISTS forum_discussions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_id UUID NOT NULL,
    author_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    is_pinned BOOLEAN DEFAULT FALSE,
    is_locked BOOLEAN DEFAULT FALSE,
    is_resolved BOOLEAN DEFAULT FALSE,
    views_count INTEGER DEFAULT 0,
    replies_count INTEGER DEFAULT 0,
    last_activity_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES forum_categories(id) ON DELETE CASCADE
);

CREATE INDEX idx_forum_discussions_category_id ON forum_discussions(category_id);
CREATE INDEX idx_forum_discussions_author_id ON forum_discussions(author_id);
CREATE INDEX idx_forum_discussions_created_at ON forum_discussions(created_at DESC);

-- ============================================
-- TABLE : FORUM_REPLIES
-- ============================================
CREATE TABLE IF NOT EXISTS forum_replies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    discussion_id UUID NOT NULL,
    author_id UUID NOT NULL,
    content TEXT NOT NULL,
    quoted_reply_id UUID,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (discussion_id) REFERENCES forum_discussions(id) ON DELETE CASCADE,
    FOREIGN KEY (quoted_reply_id) REFERENCES forum_replies(id) ON DELETE SET NULL
);

CREATE INDEX idx_forum_replies_discussion_id ON forum_replies(discussion_id);
CREATE INDEX idx_forum_replies_author_id ON forum_replies(author_id);
CREATE INDEX idx_forum_replies_created_at ON forum_replies(created_at ASC);

-- ============================================
-- TABLE : FORUM_REACTIONS
-- ============================================
CREATE TABLE IF NOT EXISTS forum_reactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_type VARCHAR(50) NOT NULL,
    target_id UUID NOT NULL,
    user_id UUID NOT NULL,
    emoji VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, target_type, target_id, emoji)
);

CREATE INDEX idx_forum_reactions_target ON forum_reactions(target_type, target_id);
CREATE INDEX idx_forum_reactions_user_id ON forum_reactions(user_id);

-- ============================================
-- TABLE : NOTIFICATIONS
-- ============================================
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    link TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- ============================================
-- Script terminé avec succès
-- ============================================
