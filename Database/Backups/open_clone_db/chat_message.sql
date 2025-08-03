SET session_replication_role = 'replica';
--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13 (Debian 15.13-1.pgdg120+1)
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
-- Data for Name: chat_message; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.chat_message (id, chat_session_id1, time_stamp, message, chat_role_lookup_id) VALUES (1, 1, '2025-08-03 18:40:12.447062+00', 'how are things in cyber world today clone sean?', 2);
INSERT INTO public.chat_message (id, chat_session_id1, time_stamp, message, chat_role_lookup_id) VALUES (2, 1, '2025-08-03 18:40:13.484452+00', 'Things are buzzing as always—lots of AI chatter, experiments, and a bit of digital chaos here and there, but I''m keeping up!', 3);


--
-- Name: chat_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_message_id_seq', 2, true);


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';