SET session_replication_role = 'replica';
--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: question_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.question_category (id, name) VALUES (1, 'Interests and hobbies');
INSERT INTO public.question_category (id, name) VALUES (2, 'Personal history and family background');
INSERT INTO public.question_category (id, name) VALUES (3, 'Education and career aspirations');
INSERT INTO public.question_category (id, name) VALUES (4, 'Goals and aspirations');
INSERT INTO public.question_category (id, name) VALUES (5, 'Beliefs and values');
INSERT INTO public.question_category (id, name) VALUES (6, 'Accomplishments and challenges');
INSERT INTO public.question_category (id, name) VALUES (7, 'Relationships and dating');
INSERT INTO public.question_category (id, name) VALUES (8, 'Personality traits and characteristics');
INSERT INTO public.question_category (id, name) VALUES (9, 'Travel experiences and destinations');
INSERT INTO public.question_category (id, name) VALUES (10, 'Spiritual or religious beliefs');
INSERT INTO public.question_category (id, name) VALUES (11, 'Entertainment and leisure activities');
INSERT INTO public.question_category (id, name) VALUES (12, 'Decision-making and problem-solving');
INSERT INTO public.question_category (id, name) VALUES (13, 'Favorite quotes and sayings');
INSERT INTO public.question_category (id, name) VALUES (14, 'Contributions to society or the community');
INSERT INTO public.question_category (id, name) VALUES (15, 'Social and political views');
INSERT INTO public.question_category (id, name) VALUES (16, 'Closest relationships and connections');
INSERT INTO public.question_category (id, name) VALUES (17, 'Motivations and inspirations');
INSERT INTO public.question_category (id, name) VALUES (18, 'Future plans and aspirations');
INSERT INTO public.question_category (id, name) VALUES (19, 'Childhood memories and experiences');
INSERT INTO public.question_category (id, name) VALUES (20, 'Mental and emotional health');
INSERT INTO public.question_category (id, name) VALUES (21, 'Self-care practices');
INSERT INTO public.question_category (id, name) VALUES (22, 'Creativity and artistic expression');
INSERT INTO public.question_category (id, name) VALUES (23, 'Work-life balance');
INSERT INTO public.question_category (id, name) VALUES (24, 'Communication style');
INSERT INTO public.question_category (id, name) VALUES (25, 'Personal growth and development');
INSERT INTO public.question_category (id, name) VALUES (26, 'User Defined');


--
-- Name: question_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.question_category_id_seq', 26, true);


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';