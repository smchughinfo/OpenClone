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
-- Data for Name: asp_net_users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.asp_net_users (id, active_clone_id, user_name, normalized_user_name, email, normalized_email, email_confirmed, password_hash, security_stamp, concurrency_stamp, phone_number, phone_number_confirmed, two_factor_enabled, lockout_end, lockout_enabled, access_failed_count) VALUES ('42bb71b9-a5c5-49dc-832d-b61a83dc23e9', NULL, 'test@test.com', 'TEST@TEST.COM', 'test@test.com', 'TEST@TEST.COM', true, 'AQAAAAIAAYagAAAAEM0c0YBfGT3iu91Ee4nxTptfJ0PEQdtVSrCUT6EC6ryGER4Z7OZDBYANHi1SLxIx4g==', 'KPTU5AFACDHDFR7BQ4SP4A3SNWOIPVYC', '6b259ba8-6359-4322-b25f-07b9760db492', NULL, false, false, NULL, true, 0);
INSERT INTO public.asp_net_users (id, active_clone_id, user_name, normalized_user_name, email, normalized_email, email_confirmed, password_hash, security_stamp, concurrency_stamp, phone_number, phone_number_confirmed, two_factor_enabled, lockout_end, lockout_enabled, access_failed_count) VALUES ('8634b089-149e-48a8-b8c2-fc2d4a40df2a', 2, 'seanmchugh513@gmail.com', 'SEANMCHUGH513@GMAIL.COM', 'seanmchugh513@gmail.com', 'SEANMCHUGH513@GMAIL.COM', true, NULL, 'OCB67HAPPHVDWXD7ZWAVRS2YSUVJD4MD', '66f1e8d3-190e-4c8b-9326-2d2d24b69e69', NULL, false, false, NULL, true, 0);
INSERT INTO public.asp_net_users (id, active_clone_id, user_name, normalized_user_name, email, normalized_email, email_confirmed, password_hash, security_stamp, concurrency_stamp, phone_number, phone_number_confirmed, two_factor_enabled, lockout_end, lockout_enabled, access_failed_count) VALUES ('9e965efb-1f9b-4ef5-93bc-8778a7c10ff6', NULL, 'seanmchugh.info@gmail.com', 'SEANMCHUGH.INFO@GMAIL.COM', 'seanmchugh.info@gmail.com', 'SEANMCHUGH.INFO@GMAIL.COM', true, NULL, '5X3VQVLAKSM67DCTUJSM73YX4OEVHPAG', 'a0067253-6825-48d6-aa6f-f8c8067899b3', NULL, false, false, NULL, true, 0);
INSERT INTO public.asp_net_users (id, active_clone_id, user_name, normalized_user_name, email, normalized_email, email_confirmed, password_hash, security_stamp, concurrency_stamp, phone_number, phone_number_confirmed, two_factor_enabled, lockout_end, lockout_enabled, access_failed_count) VALUES ('d2593ec4-9d7f-41c4-89ea-0be19a92b251', 4, 'seanmchugh1@protonmail.com', 'SEANMCHUGH1@PROTONMAIL.COM', 'seanmchugh1@protonmail.com', 'SEANMCHUGH1@PROTONMAIL.COM', true, 'AQAAAAIAAYagAAAAEA5V4EpqDjWuSF4Hhri8lCW0tuM1j2YT38kxzUgrdR44Nmm2gZKQAyJ6zWe9BuMAHw==', 'BVKNBG6MFTIYWI5TIICNINMSQOZHNY5P', 'ea531507-efd3-4be1-8c0c-c0ca31f6eb51', NULL, false, false, NULL, true, 0);


--
-- PostgreSQL database dump complete
--


SET session_replication_role = 'origin';