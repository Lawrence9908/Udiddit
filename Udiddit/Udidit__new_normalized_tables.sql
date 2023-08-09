---------------------------------------------------
-- DATABASE TABLES
---------------------------------------------------
-- Create users table for new data
CREATE TABLE users (
  "id" SERIAL PRIMARY KEY, 
  "username" VARCHAR(25) NOT NULL UNIQUE, 
  "loggin_time" TIMESTAMP, 
  CONSTRAINT "username_length" CHECK(
    Length(
      Trim("username")
    )> 0
  )
);
-- Create topics table
CREATE TABLE topics (
  "id" SERIAL PRIMARY KEY, 
  "name" VARCHAR(30) NOT NULL UNIQUE, 
  "description" VARCHAR(500), 
  "user_id" INT REFERENCES users(id) ON DELETE 
  SET 
    NULL, 
    CONSTRAINT "topic_name_length" CHECK(
      Length(
        Trim("name")
      )> 0
    )
);
-- Create posts table
CREATE TABLE posts (
  "id" SERIAL PRIMARY KEY, 
  "title" VARCHAR(100) NOT NULL, 
  "url" VARCHAR(4000), 
  "text_content" TEXT, 
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
  "user_id" INT REFERENCES users(id) ON DELETE 
  SET 
    NULL, 
    "topic_id" INT REFERENCES topics(id) ON DELETE CASCADE NOT NULL, 
    CONSTRAINT "text_content_or_url" CHECK(
      (
        ("url") IS NULL 
        AND ("text_content") IS NOT NULL
      ) 
      OR (
        ("url") IS NOT NULL 
        AND ("text_content") IS NULL
      )
    ), 
    CONSTRAINT "post_title_length" CHECK(
      Length(
        Trim("title")
      )> 0
    )
);
-- Create comments table
CREATE TABLE comments (
  "id" SERIAL PRIMARY KEY, 
  "comment" TEXT NOT NULL, 
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
  "user_id" INT REFERENCES users(id) ON DELETE 
  SET 
    NULL, 
    "post_id" INT REFERENCES posts(id) ON DELETE CASCADE, 
    "parent_comment_id" INT REFERENCES comments(id) ON DELETE CASCADE, 
    "topic_id" INT REFERENCES topics(id) ON DELETE CASCADE NOT NULL, 
    CONSTRAINT "comment_not_empty" CHECK(
      Length(
        Trim("comment")
      )> 0
    )
);
-- Create votes table
CREATE TABLE votes (
  "id" SERIAL PRIMARY KEY, 
  "vote_value" INT CHECK (
    vote_value = 1 
    OR vote_value = -1
  ), 
  "created_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
  "user_id" INT REFERENCES users(id) ON DELETE 
  SET 
    NULL, 
    "post_id" INT REFERENCES posts(id) ON DELETE CASCADE, 
    "topic_id" INT REFERENCES topics(id) ON DELETE CASCADE NOT NULL
);
