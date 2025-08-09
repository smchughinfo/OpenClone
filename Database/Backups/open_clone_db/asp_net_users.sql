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
-- Data for Name: asp_net_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.asp_net_users (id, active_clone_id, user_name, normalized_user_name, email, normalized_email, email_confirmed, password_hash, security_stamp, concurrency_stamp, phone_number, phone_number_confirmed, two_factor_enabled, lockout_end, lockout_enabled, access_failed_count) VALUES ('8634b089-149e-48a8-b8c2-fc2d4a40df2a', 2, 'seanmchugh513@gmail.com', 'SEANMCHUGH513@GMAIL.COM', 'seanmchugh513@gmail.com', 'SEANMCHUGH513@GMAIL.COM', true, NULL, 'OCB67HAPPHVDWXD7ZWAVRS2YSUVJD4MD', '66f1e8d3-190e-4c8b-9326-2d2d24b69e69', NULL, false, false, NULL, true, 0);


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';