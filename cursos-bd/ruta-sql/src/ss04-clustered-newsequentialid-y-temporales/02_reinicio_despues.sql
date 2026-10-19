-- sqlserver
-- ss04 · §8. Segunda parte, después de reiniciar: 1.000 filas más, y dónde cayeron respecto de las de antes.
USE ss04;
INSERT INTO dbo.seq_restart (tanda) SELECT TOP (1000) 2 FROM sys.all_objects;
SELECT tanda, COUNT(*) AS filas, MIN(id) AS menor, MAX(id) AS mayor FROM dbo.seq_restart GROUP BY tanda ORDER BY tanda;
-- ¿Cuántas de la tanda 2 quedaron ordenadas antes de la última de la tanda 1? Si son todas, el índice crece por el medio.
SELECT COUNT(*) AS tanda2_antes_del_maximo_de_tanda1
FROM dbo.seq_restart WHERE tanda = 2 AND id < (SELECT MAX(id) FROM dbo.seq_restart WHERE tanda = 1);
GO
