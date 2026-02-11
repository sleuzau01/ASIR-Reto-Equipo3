-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 26, 2026 at 08:58 AM
-- Server version: 8.0.43
-- PHP Version: 8.3.26

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `estadio_racing_bares`
--
CREATE DATABASE IF NOT EXISTS `estadio_racing_bares` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `estadio_racing_bares`;

-- --------------------------------------------------------

--
-- Table structure for table `alertas_stock`
--

DROP TABLE IF EXISTS `alertas_stock`;
CREATE TABLE IF NOT EXISTS `alertas_stock` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bar_id` int NOT NULL,
  `producto_id` int NOT NULL,
  `tipo_alerta` enum('Stock_Bajo','Agotado') COLLATE utf8mb4_unicode_ci NOT NULL,
  `stock_en_alerta` int DEFAULT NULL,
  `notificado` tinyint(1) DEFAULT '0',
  `fecha_alerta` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `bar_id` (`bar_id`),
  KEY `producto_id` (`producto_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `bares`
--

DROP TABLE IF EXISTS `bares`;
CREATE TABLE IF NOT EXISTS `bares` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ubicacion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` enum('Abierto','Cerrado','Mantenimiento') COLLATE utf8mb4_unicode_ci DEFAULT 'Abierto',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `bares`
--

INSERT INTO `bares` (`id`, `nombre`, `ubicacion`, `estado`) VALUES
(1, 'Gol Norte 1', 'Grada Norte', 'Abierto'),
(2, 'Gol Norte 2', 'Grada Norte', 'Abierto'),
(3, 'Preferencia Central', 'Tribuna', 'Abierto'),
(4, 'Preferencia Lateral', 'Tribuna', 'Abierto'),
(5, 'Fondo Sur 1', 'Grada Sur', 'Abierto'),
(6, 'Fondo Sur 2', 'Grada Sur', 'Abierto'),
(7, 'Lateral Este 1', 'Grada Este', 'Abierto'),
(8, 'Lateral Este 2', 'Grada Este', 'Abierto'),
(9, 'Lateral Oeste 1', 'Grada Oeste', 'Abierto'),
(10, 'Lateral Oeste 2', 'Grada Oeste', 'Abierto'),
(11, 'VIP Tribuna', 'Zona VIP', 'Abierto'),
(12, 'Acceso Principal', 'Vestíbulo', 'Abierto'),
(13, 'Media Press', 'Prensa', 'Abierto'),
(14, 'Jugadores Familia', 'Directiva', 'Abierto'),
(15, 'Corner Norte', 'Esquina N', 'Abierto'),
(16, 'Corner Sur', 'Esquina S', 'Abierto');

-- --------------------------------------------------------

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
CREATE TABLE IF NOT EXISTS `productos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `categoria` enum('Bebida','Comida','Merchandising') COLLATE utf8mb4_unicode_ci NOT NULL,
  `precio_base` decimal(10,2) NOT NULL,
  `stock_almacen_central` int DEFAULT '0',
  `codigo_barra` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `codigo_barra` (`codigo_barra`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `productos`
--

INSERT INTO `productos` (`id`, `nombre`, `categoria`, `precio_base`, `stock_almacen_central`, `codigo_barra`, `activo`) VALUES
(1, 'Palomitas', 'Comida', 1.50, 1600, 'SNK001', 1),
(2, 'Regaliz', 'Comida', 1.50, 1600, 'SNK002', 1),
(3, 'Chaskis', 'Comida', 1.50, 1600, 'SNK003', 1),
(4, 'Chuches Azúcar', 'Comida', 1.50, 1600, 'SNK004', 1),
(5, 'Chuches Sin Azúcar', 'Comida', 1.50, 1600, 'SNK005', 1),
(6, 'Patatas Fritas', 'Comida', 2.00, 1600, 'SNK006', 1),
(7, 'Pipas', 'Comida', 2.00, 1600, 'SNK007', 1),
(8, 'Pipas con Sal', 'Comida', 2.00, 1600, 'SNK008', 1),
(9, 'Napolitana', 'Comida', 2.00, 1600, 'COM001', 1),
(10, 'Donut', 'Comida', 2.00, 1600, 'COM002', 1),
(11, 'Palmera', 'Comida', 3.00, 1600, 'COM003', 1),
(12, 'Bocadillo', 'Comida', 4.00, 1600, 'COM004', 1),
(13, 'Empanada', 'Comida', 4.00, 1600, 'COM005', 1),
(14, 'Bollo Preñado', 'Comida', 4.00, 1600, 'COM006', 1),
(15, 'Helado', 'Comida', 4.00, 1600, 'POST001', 1),
(16, 'Café', 'Bebida', 2.00, 1600, 'BEB001', 1),
(17, 'Agua', 'Bebida', 2.00, 1600, 'BEB002', 1),
(18, 'Coca-Cola Normal', 'Bebida', 3.50, 1600, 'BEB003', 1),
(19, 'Coca-Cola Zero', 'Bebida', 3.50, 1600, 'BEB004', 1),
(20, 'Fanta Naranja', 'Bebida', 3.50, 1600, 'BEB005', 1),
(21, 'Aquarius Limón', 'Bebida', 3.50, 1600, 'BEB006', 1),
(22, 'Fuze Tea', 'Bebida', 3.50, 1600, 'BEB007', 1),
(23, 'Cerveza', 'Bebida', 3.50, 1600, 'BEB008', 1);

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
CREATE TABLE IF NOT EXISTS `roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `permisos` json DEFAULT NULL,
  `descripcion` text COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `nombre`, `permisos`, `descripcion`) VALUES
(1, 'Admin Global', '{\"admin\": true}', 'Gestión total'),
(2, 'Encargado', '{\"stock\": true}', 'Manager'),
(3, 'Camarero', '{\"cobrar\": true}', 'Operador');

-- --------------------------------------------------------

--
-- Table structure for table `stock_bares`
--

DROP TABLE IF EXISTS `stock_bares`;
CREATE TABLE IF NOT EXISTS `stock_bares` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bar_id` int NOT NULL,
  `producto_id` int NOT NULL,
  `stock_actual` int DEFAULT '0',
  `stock_minimo` int DEFAULT '20',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_bar_producto` (`bar_id`,`producto_id`),
  KEY `producto_id` (`producto_id`)
) ENGINE=InnoDB AUTO_INCREMENT=512 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `stock_bares`
--

INSERT INTO `stock_bares` (`id`, `bar_id`, `producto_id`, `stock_actual`, `stock_minimo`) VALUES
(1, 16, 16, 100, 20),
(2, 15, 16, 100, 20),
(3, 14, 16, 100, 20),
(4, 13, 16, 100, 20),
(5, 12, 16, 100, 20),
(6, 11, 16, 100, 20),
(7, 10, 16, 100, 20),
(8, 9, 16, 100, 20),
(9, 8, 16, 100, 20),
(10, 7, 16, 100, 20),
(11, 6, 16, 100, 20),
(12, 5, 16, 100, 20),
(13, 4, 16, 100, 20),
(14, 3, 16, 100, 20),
(15, 2, 16, 100, 20),
(16, 1, 16, 100, 20),
(17, 16, 17, 100, 20),
(18, 15, 17, 100, 20),
(19, 14, 17, 100, 20),
(20, 13, 17, 100, 20),
(21, 12, 17, 100, 20),
(22, 11, 17, 100, 20),
(23, 10, 17, 100, 20),
(24, 9, 17, 100, 20),
(25, 8, 17, 100, 20),
(26, 7, 17, 100, 20),
(27, 6, 17, 100, 20),
(28, 5, 17, 100, 20),
(29, 4, 17, 100, 20),
(30, 3, 17, 100, 20),
(31, 2, 17, 100, 20),
(32, 1, 17, 100, 20),
(33, 16, 18, 100, 20),
(34, 15, 18, 100, 20),
(35, 14, 18, 100, 20),
(36, 13, 18, 100, 20),
(37, 12, 18, 100, 20),
(38, 11, 18, 100, 20),
(39, 10, 18, 100, 20),
(40, 9, 18, 100, 20),
(41, 8, 18, 100, 20),
(42, 7, 18, 100, 20),
(43, 6, 18, 100, 20),
(44, 5, 18, 100, 20),
(45, 4, 18, 100, 20),
(46, 3, 18, 100, 20),
(47, 2, 18, 97, 20),
(48, 1, 18, 100, 20),
(49, 16, 19, 100, 20),
(50, 15, 19, 100, 20),
(51, 14, 19, 100, 20),
(52, 13, 19, 100, 20),
(53, 12, 19, 100, 20),
(54, 11, 19, 100, 20),
(55, 10, 19, 100, 20),
(56, 9, 19, 100, 20),
(57, 8, 19, 100, 20),
(58, 7, 19, 100, 20),
(59, 6, 19, 100, 20),
(60, 5, 19, 100, 20),
(61, 4, 19, 100, 20),
(62, 3, 19, 100, 20),
(63, 2, 19, 100, 20),
(64, 1, 19, 100, 20),
(65, 16, 20, 100, 20),
(66, 15, 20, 100, 20),
(67, 14, 20, 100, 20),
(68, 13, 20, 100, 20),
(69, 12, 20, 100, 20),
(70, 11, 20, 100, 20),
(71, 10, 20, 100, 20),
(72, 9, 20, 100, 20),
(73, 8, 20, 100, 20),
(74, 7, 20, 100, 20),
(75, 6, 20, 100, 20),
(76, 5, 20, 100, 20),
(77, 4, 20, 100, 20),
(78, 3, 20, 100, 20),
(79, 2, 20, 100, 20),
(80, 1, 20, 100, 20),
(81, 16, 21, 100, 20),
(82, 15, 21, 100, 20),
(83, 14, 21, 100, 20),
(84, 13, 21, 100, 20),
(85, 12, 21, 100, 20),
(86, 11, 21, 100, 20),
(87, 10, 21, 100, 20),
(88, 9, 21, 100, 20),
(89, 8, 21, 100, 20),
(90, 7, 21, 100, 20),
(91, 6, 21, 100, 20),
(92, 5, 21, 100, 20),
(93, 4, 21, 100, 20),
(94, 3, 21, 100, 20),
(95, 2, 21, 100, 20),
(96, 1, 21, 100, 20),
(97, 16, 22, 100, 20),
(98, 15, 22, 100, 20),
(99, 14, 22, 100, 20),
(100, 13, 22, 100, 20),
(101, 12, 22, 100, 20),
(102, 11, 22, 100, 20),
(103, 10, 22, 100, 20),
(104, 9, 22, 100, 20),
(105, 8, 22, 100, 20),
(106, 7, 22, 100, 20),
(107, 6, 22, 100, 20),
(108, 5, 22, 100, 20),
(109, 4, 22, 100, 20),
(110, 3, 22, 100, 20),
(111, 2, 22, 100, 20),
(112, 1, 22, 100, 20),
(113, 16, 23, 100, 20),
(114, 15, 23, 100, 20),
(115, 14, 23, 100, 20),
(116, 13, 23, 100, 20),
(117, 12, 23, 100, 20),
(118, 11, 23, 100, 20),
(119, 10, 23, 100, 20),
(120, 9, 23, 100, 20),
(121, 8, 23, 100, 20),
(122, 7, 23, 100, 20),
(123, 6, 23, 100, 20),
(124, 5, 23, 100, 20),
(125, 4, 23, 100, 20),
(126, 3, 23, 100, 20),
(127, 2, 23, 100, 20),
(128, 1, 23, 98, 20),
(129, 16, 9, 100, 20),
(130, 15, 9, 100, 20),
(131, 14, 9, 100, 20),
(132, 13, 9, 100, 20),
(133, 12, 9, 100, 20),
(134, 11, 9, 100, 20),
(135, 10, 9, 100, 20),
(136, 9, 9, 100, 20),
(137, 8, 9, 100, 20),
(138, 7, 9, 100, 20),
(139, 6, 9, 100, 20),
(140, 5, 9, 100, 20),
(141, 4, 9, 100, 20),
(142, 3, 9, 100, 20),
(143, 2, 9, 100, 20),
(144, 1, 9, 100, 20),
(145, 16, 10, 100, 20),
(146, 15, 10, 100, 20),
(147, 14, 10, 100, 20),
(148, 13, 10, 100, 20),
(149, 12, 10, 100, 20),
(150, 11, 10, 100, 20),
(151, 10, 10, 100, 20),
(152, 9, 10, 100, 20),
(153, 8, 10, 100, 20),
(154, 7, 10, 100, 20),
(155, 6, 10, 100, 20),
(156, 5, 10, 100, 20),
(157, 4, 10, 100, 20),
(158, 3, 10, 100, 20),
(159, 2, 10, 100, 20),
(160, 1, 10, 100, 20),
(161, 16, 11, 100, 20),
(162, 15, 11, 100, 20),
(163, 14, 11, 100, 20),
(164, 13, 11, 100, 20),
(165, 12, 11, 100, 20),
(166, 11, 11, 100, 20),
(167, 10, 11, 100, 20),
(168, 9, 11, 100, 20),
(169, 8, 11, 100, 20),
(170, 7, 11, 100, 20),
(171, 6, 11, 100, 20),
(172, 5, 11, 100, 20),
(173, 4, 11, 100, 20),
(174, 3, 11, 100, 20),
(175, 2, 11, 100, 20),
(176, 1, 11, 100, 20),
(177, 16, 12, 100, 20),
(178, 15, 12, 100, 20),
(179, 14, 12, 100, 20),
(180, 13, 12, 100, 20),
(181, 12, 12, 100, 20),
(182, 11, 12, 100, 20),
(183, 10, 12, 100, 20),
(184, 9, 12, 100, 20),
(185, 8, 12, 100, 20),
(186, 7, 12, 100, 20),
(187, 6, 12, 100, 20),
(188, 5, 12, 100, 20),
(189, 4, 12, 100, 20),
(190, 3, 12, 100, 20),
(191, 2, 12, 100, 20),
(192, 1, 12, 100, 20),
(193, 16, 13, 100, 20),
(194, 15, 13, 100, 20),
(195, 14, 13, 100, 20),
(196, 13, 13, 100, 20),
(197, 12, 13, 100, 20),
(198, 11, 13, 100, 20),
(199, 10, 13, 100, 20),
(200, 9, 13, 100, 20),
(201, 8, 13, 100, 20),
(202, 7, 13, 100, 20),
(203, 6, 13, 100, 20),
(204, 5, 13, 100, 20),
(205, 4, 13, 100, 20),
(206, 3, 13, 100, 20),
(207, 2, 13, 100, 20),
(208, 1, 13, 100, 20),
(209, 16, 14, 100, 20),
(210, 15, 14, 100, 20),
(211, 14, 14, 100, 20),
(212, 13, 14, 100, 20),
(213, 12, 14, 100, 20),
(214, 11, 14, 100, 20),
(215, 10, 14, 100, 20),
(216, 9, 14, 100, 20),
(217, 8, 14, 100, 20),
(218, 7, 14, 100, 20),
(219, 6, 14, 100, 20),
(220, 5, 14, 100, 20),
(221, 4, 14, 100, 20),
(222, 3, 14, 100, 20),
(223, 2, 14, 100, 20),
(224, 1, 14, 100, 20),
(225, 16, 15, 100, 20),
(226, 15, 15, 100, 20),
(227, 14, 15, 100, 20),
(228, 13, 15, 100, 20),
(229, 12, 15, 100, 20),
(230, 11, 15, 100, 20),
(231, 10, 15, 100, 20),
(232, 9, 15, 100, 20),
(233, 8, 15, 100, 20),
(234, 7, 15, 100, 20),
(235, 6, 15, 100, 20),
(236, 5, 15, 100, 20),
(237, 4, 15, 100, 20),
(238, 3, 15, 100, 20),
(239, 2, 15, 100, 20),
(240, 1, 15, 100, 20),
(241, 16, 1, 100, 20),
(242, 15, 1, 100, 20),
(243, 14, 1, 100, 20),
(244, 13, 1, 100, 20),
(245, 12, 1, 100, 20),
(246, 11, 1, 100, 20),
(247, 10, 1, 100, 20),
(248, 9, 1, 100, 20),
(249, 8, 1, 100, 20),
(250, 7, 1, 100, 20),
(251, 6, 1, 100, 20),
(252, 5, 1, 100, 20),
(253, 4, 1, 100, 20),
(254, 3, 1, 100, 20),
(255, 2, 1, 99, 20),
(256, 1, 1, 100, 20),
(257, 16, 2, 100, 20),
(258, 15, 2, 100, 20),
(259, 14, 2, 100, 20),
(260, 13, 2, 100, 20),
(261, 12, 2, 100, 20),
(262, 11, 2, 100, 20),
(263, 10, 2, 100, 20),
(264, 9, 2, 100, 20),
(265, 8, 2, 100, 20),
(266, 7, 2, 100, 20),
(267, 6, 2, 100, 20),
(268, 5, 2, 100, 20),
(269, 4, 2, 100, 20),
(270, 3, 2, 100, 20),
(271, 2, 2, 100, 20),
(272, 1, 2, 100, 20),
(273, 16, 3, 100, 20),
(274, 15, 3, 100, 20),
(275, 14, 3, 100, 20),
(276, 13, 3, 100, 20),
(277, 12, 3, 100, 20),
(278, 11, 3, 100, 20),
(279, 10, 3, 100, 20),
(280, 9, 3, 100, 20),
(281, 8, 3, 100, 20),
(282, 7, 3, 100, 20),
(283, 6, 3, 100, 20),
(284, 5, 3, 100, 20),
(285, 4, 3, 100, 20),
(286, 3, 3, 100, 20),
(287, 2, 3, 100, 20),
(288, 1, 3, 100, 20),
(289, 16, 4, 100, 20),
(290, 15, 4, 100, 20),
(291, 14, 4, 100, 20),
(292, 13, 4, 100, 20),
(293, 12, 4, 100, 20),
(294, 11, 4, 100, 20),
(295, 10, 4, 100, 20),
(296, 9, 4, 100, 20),
(297, 8, 4, 100, 20),
(298, 7, 4, 100, 20),
(299, 6, 4, 100, 20),
(300, 5, 4, 100, 20),
(301, 4, 4, 100, 20),
(302, 3, 4, 100, 20),
(303, 2, 4, 100, 20),
(304, 1, 4, 100, 20),
(305, 16, 5, 100, 20),
(306, 15, 5, 100, 20),
(307, 14, 5, 100, 20),
(308, 13, 5, 100, 20),
(309, 12, 5, 100, 20),
(310, 11, 5, 100, 20),
(311, 10, 5, 100, 20),
(312, 9, 5, 100, 20),
(313, 8, 5, 100, 20),
(314, 7, 5, 100, 20),
(315, 6, 5, 100, 20),
(316, 5, 5, 100, 20),
(317, 4, 5, 100, 20),
(318, 3, 5, 100, 20),
(319, 2, 5, 100, 20),
(320, 1, 5, 100, 20),
(321, 16, 6, 100, 20),
(322, 15, 6, 100, 20),
(323, 14, 6, 100, 20),
(324, 13, 6, 100, 20),
(325, 12, 6, 100, 20),
(326, 11, 6, 100, 20),
(327, 10, 6, 100, 20),
(328, 9, 6, 100, 20),
(329, 8, 6, 100, 20),
(330, 7, 6, 100, 20),
(331, 6, 6, 100, 20),
(332, 5, 6, 100, 20),
(333, 4, 6, 100, 20),
(334, 3, 6, 100, 20),
(335, 2, 6, 100, 20),
(336, 1, 6, 99, 20),
(337, 16, 7, 100, 20),
(338, 15, 7, 100, 20),
(339, 14, 7, 100, 20),
(340, 13, 7, 100, 20),
(341, 12, 7, 100, 20),
(342, 11, 7, 100, 20),
(343, 10, 7, 100, 20),
(344, 9, 7, 100, 20),
(345, 8, 7, 100, 20),
(346, 7, 7, 100, 20),
(347, 6, 7, 100, 20),
(348, 5, 7, 100, 20),
(349, 4, 7, 100, 20),
(350, 3, 7, 100, 20),
(351, 2, 7, 100, 20),
(352, 1, 7, 100, 20),
(353, 16, 8, 100, 20),
(354, 15, 8, 100, 20),
(355, 14, 8, 100, 20),
(356, 13, 8, 100, 20),
(357, 12, 8, 100, 20),
(358, 11, 8, 100, 20),
(359, 10, 8, 100, 20),
(360, 9, 8, 100, 20),
(361, 8, 8, 100, 20),
(362, 7, 8, 100, 20),
(363, 6, 8, 100, 20),
(364, 5, 8, 100, 20),
(365, 4, 8, 100, 20),
(366, 3, 8, 100, 20),
(367, 2, 8, 100, 20),
(368, 1, 8, 100, 20);

--
-- Triggers `stock_bares`
--
DROP TRIGGER IF EXISTS `trg_alerta_stock_bajo`;
DELIMITER $$
CREATE TRIGGER `trg_alerta_stock_bajo` AFTER UPDATE ON `stock_bares` FOR EACH ROW BEGIN
    IF NEW.stock_actual <= NEW.stock_minimo AND OLD.stock_actual > NEW.stock_minimo THEN
        INSERT INTO alertas_stock (bar_id, producto_id, tipo_alerta, stock_en_alerta)
        VALUES (NEW.bar_id, NEW.producto_id, 
                IF(NEW.stock_actual = 0, 'Agotado', 'Stock_Bajo'), 
                NEW.stock_actual);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int NOT NULL AUTO_INCREMENT,
  `rol_id` int NOT NULL,
  `nombre_completo` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `activo` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  KEY `rol_id` (`rol_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `usuarios`
--

INSERT INTO `usuarios` (`id`, `rol_id`, `nombre_completo`, `username`, `password_hash`, `activo`) VALUES
(1, 1, 'Admin Racing', 'ADMIN', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(2, 3, 'María García', 'MARIA001', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(3, 3, 'Pedro López', 'PEDRO002', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1),
(4, 2, 'Laura Martínez', 'LAURA_ENC', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 1);

-- --------------------------------------------------------

--
-- Table structure for table `ventas`
--

DROP TABLE IF EXISTS `ventas`;
CREATE TABLE IF NOT EXISTS `ventas` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bar_id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `fecha_venta` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `metodo_pago` enum('Efectivo','Tarjeta','Movil_NFC','Abono') COLLATE utf8mb4_unicode_ci NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `numero_transaccion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado` enum('Completada','Cancelada') COLLATE utf8mb4_unicode_ci DEFAULT 'Completada',
  PRIMARY KEY (`id`),
  KEY `bar_id` (`bar_id`),
  KEY `usuario_id` (`usuario_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ventas`
--

INSERT INTO `ventas` (`id`, `bar_id`, `usuario_id`, `fecha_venta`, `metodo_pago`, `total`, `numero_transaccion`, `estado`) VALUES
(1, 1, 2, '2026-01-23 12:16:29', 'Tarjeta', 9.00, 'TX001', 'Completada'),
(2, 2, 3, '2026-01-23 12:16:29', 'Movil_NFC', 12.50, 'TX002', 'Completada');

-- --------------------------------------------------------

--
-- Table structure for table `ventas_detalle`
--

DROP TABLE IF EXISTS `ventas_detalle`;
CREATE TABLE IF NOT EXISTS `ventas_detalle` (
  `id` int NOT NULL AUTO_INCREMENT,
  `venta_id` int NOT NULL,
  `producto_id` int NOT NULL,
  `cantidad` int NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) GENERATED ALWAYS AS ((`cantidad` * `precio_unitario`)) STORED,
  PRIMARY KEY (`id`),
  KEY `venta_id` (`venta_id`),
  KEY `producto_id` (`producto_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ventas_detalle`
--

INSERT INTO `ventas_detalle` (`id`, `venta_id`, `producto_id`, `cantidad`, `precio_unitario`) VALUES
(1, 1, 23, 2, 3.50),
(2, 1, 6, 1, 2.00),
(3, 2, 18, 3, 3.50),
(4, 2, 1, 1, 1.50);

--
-- Triggers `ventas_detalle`
--
DROP TRIGGER IF EXISTS `trg_venta_reduce_stock`;
DELIMITER $$
CREATE TRIGGER `trg_venta_reduce_stock` AFTER INSERT ON `ventas_detalle` FOR EACH ROW BEGIN
    DECLARE v_bar_id INT;
    SELECT bar_id INTO v_bar_id FROM ventas WHERE id = NEW.venta_id;
    UPDATE stock_bares SET stock_actual = stock_actual - NEW.cantidad
    WHERE bar_id = v_bar_id AND producto_id = NEW.producto_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_stock_critico`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `vw_stock_critico`;
CREATE TABLE IF NOT EXISTS `vw_stock_critico` (
`bar` varchar(50)
,`estado` varchar(7)
,`producto` varchar(100)
,`stock_actual` int
,`stock_minimo` int
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_ventas_empleados`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `vw_ventas_empleados`;
CREATE TABLE IF NOT EXISTS `vw_ventas_empleados` (
`bar` varchar(50)
,`empleado` varchar(100)
,`facturado` decimal(32,2)
,`ticket_medio` decimal(14,6)
,`tickets` bigint
);

-- --------------------------------------------------------

--
-- Structure for view `vw_stock_critico`
--
DROP TABLE IF EXISTS `vw_stock_critico`;

DROP VIEW IF EXISTS `vw_stock_critico`;
CREATE OR REPLACE VIEW `vw_stock_critico`  AS SELECT `b`.`nombre` AS `bar`, `p`.`nombre` AS `producto`, `sb`.`stock_actual` AS `stock_actual`, `sb`.`stock_minimo` AS `stock_minimo`, if((`sb`.`stock_actual` = 0),'AGOTADO','CRÍTICO') AS `estado` FROM ((`stock_bares` `sb` join `bares` `b` on((`sb`.`bar_id` = `b`.`id`))) join `productos` `p` on((`sb`.`producto_id` = `p`.`id`))) WHERE (`sb`.`stock_actual` <= `sb`.`stock_minimo`) ;

-- --------------------------------------------------------

--
-- Structure for view `vw_ventas_empleados`
--
DROP TABLE IF EXISTS `vw_ventas_empleados`;

DROP VIEW IF EXISTS `vw_ventas_empleados`;
CREATE OR REPLACE VIEW `vw_ventas_empleados`  AS SELECT `u`.`nombre_completo` AS `empleado`, `b`.`nombre` AS `bar`, count(`v`.`id`) AS `tickets`, sum(`v`.`total`) AS `facturado`, avg(`v`.`total`) AS `ticket_medio` FROM ((`ventas` `v` join `usuarios` `u` on((`v`.`usuario_id` = `u`.`id`))) join `bares` `b` on((`v`.`bar_id` = `b`.`id`))) WHERE (`v`.`estado` = 'Completada') GROUP BY `u`.`id`, `b`.`id` ORDER BY `facturado` DESC ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alertas_stock`
--
ALTER TABLE `alertas_stock`
  ADD CONSTRAINT `alertas_stock_ibfk_1` FOREIGN KEY (`bar_id`) REFERENCES `bares` (`id`),
  ADD CONSTRAINT `alertas_stock_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`);

--
-- Constraints for table `stock_bares`
--
ALTER TABLE `stock_bares`
  ADD CONSTRAINT `stock_bares_ibfk_1` FOREIGN KEY (`bar_id`) REFERENCES `bares` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `stock_bares_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `usuarios`
--
ALTER TABLE `usuarios`
  ADD CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`rol_id`) REFERENCES `roles` (`id`) ON DELETE RESTRICT;

--
-- Constraints for table `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`bar_id`) REFERENCES `bares` (`id`),
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`);

--
-- Constraints for table `ventas_detalle`
--
ALTER TABLE `ventas_detalle`
  ADD CONSTRAINT `ventas_detalle_ibfk_1` FOREIGN KEY (`venta_id`) REFERENCES `ventas` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `ventas_detalle_ibfk_2` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
