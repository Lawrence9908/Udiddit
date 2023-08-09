------------------------------------------------------------------------
--    DATA MIGRATION FROM BAD SCHEMAS TO NORMALIZED SCHEMAS
------------------------------------------------------------------------
-- Insert all unique usernames from both bad_comments and bad_posts tables
INSERT INTO users("username") 
SELECT 
  DISTINCT username 
FROM 
  bad_posts 
UNION 
SELECT 
  DISTINCT username 
FROM 
  bad_comments;
-- Insert distinct topic form bad_posts
INSERT INTO topics(name, description) 
SELECT 
  DISTINCT topic, 
  NULL 
FROM 
  bad_posts;
-- Insert fields from the "bad_posts", "users", and "topics"
-- Using sunbstring for long title to take only 100 character to store in table
INSERT INTO posts(
  "title", "url", "text_content", "user_id", 
  "topic_id"
) 
SELECT 
  substring(bad_posts.title for 100), 
  bad_posts.url, 
  bad_posts.text_content, 
  users.id AS user_id, 
  topics.id AS topic_id 
FROM 
  "bad_posts" 
  JOIN users ON users.username = bad_posts.username 
  JOIN topics ON bad_posts.topic = topics.name;
-- Migrate comments (as top-level comments)
INSERT INTO comments (
  user_id, post_id, parent_comment_id, 
  comment, topic_id
) 
SELECT 
  u.id, 
  p.id, 
  NULL, 
  bc.text_content, 
  p.topic_id 
FROM 
  bad_comments bc 
  JOIN users u ON u.username = bc.username 
  JOIN posts p ON p.id = bc.post_id;
-- Migrate votes
INSERT INTO votes (
  user_id, post_id, vote_value, topic_id
) 
SELECT 
  u.id, 
  p.id, 
  1, 
  p.topic_id 
FROM 
  bad_posts bp 
  JOIN users u ON u.username = bp.username 
  JOIN posts p ON p.title = bp.title CROSS 
  JOIN LATERAL regexp_split_to_table(bp.upvotes, ',') vote;
-- Migrate downvotes as negative votes
INSERT INTO votes (
  user_id, post_id, vote_value, topic_id
) 
SELECT 
  u.id, 
  p.id, 
  -1, 
  p.topic_id 
FROM 
  bad_posts bp 
  JOIN users u ON u.username = bp.username 
  JOIN posts p ON p.title = bp.title CROSS 
  JOIN LATERAL regexp_split_to_table(bp.downvotes, ',') vote;
