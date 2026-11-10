/*Analisis del impacto en los primeros años por el virus COVID-19*/
--1: REVISION GENERAL
SELECT location, date, total_cases, new_cases, total_deaths FROM `Covid19.COVID_DEATH`
ORDER BY 1,2

--2: PAISES DE SUDAMERICA CON MAYOR CANTIDAD DE MUERTES
SELECT iso_code,SUM(new_deaths) FROM `proyecto1-080426.Covid19.COVID_DEATH`
--WHERE continent="South America"
GROUP BY iso_code
ORDER BY SUM(new_deaths) DESC

--3: PAISES DE AMERICA CON MAYOR CANTIDAD DE MUERTES
SELECT location,SUM(new_deaths) AS Cantidad_muertes FROM `proyecto1-080426.Covid19.COVID_DEATH`
WHERE continent="South America" or continent="North America"
GROUP BY location
Order BY SUM(new_deaths) DESC

--4 OBSERVAR CASOS TOTALES FRENTE A MUERTES TOTALES
SELECT location, date, total_cases, total_deaths, (total_deaths/total_deaths)*100 AS Tasa_Mortalidad FROM `Covid19.COVID_DEATH`
ORDER BY 1,2

--5 TASA DE CONTAGIO POR PAÍS
SELECT 
  location,
  MAX((total_cases/population)*100) AS Tasa_contagio 
FROM `Covid19.COVID_DEATH`
GROUP BY location
ORDER BY Tasa_contagio DESC;

--6 PROBABILIDAD DE MORIR CUANTO TE CONTAGIAS COVID EN TU PAIS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Tasa_Mortalidad FROM `Covid19.COVID_DEATH`
ORDER BY 1,2

--7 TASA DE CONTAGIO POR PAÍS
SELECT 
  location,
  MAX(AVG((total_cases/population)*100)) AS Tasa_contagio 
FROM `Covid19.COVID_DEATH`
GROUP BY location
ORDER BY Tasa_contagio DESC;

--8 TASA DE MUERTE POR PAIS
SELECT location,population,total_deaths, MAX((total_deaths/population)*100) AS TASA_MUERTE
FROM `Covid19.COVID_DEATH`
GROUP BY location,population,total_deaths
ORDER BY TASA_MUERTE DESC;

--9 PAISES CON LA MAYOR CANTIDAD DE MUERTES(esando MAX)
SELECT location, MAX(total_deaths) FROM `Covid19.COVID_DEATH`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY MAX(total_deaths) DESC

--9 PAISES CON LA MAYOR CANTIDAD DE MUERTES(esando sum)
SELECT location, SUM(CAST(new_deaths AS int)) FROM `Covid19.COVID_DEATH`
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY SUM(CAST(new_deaths AS int)) DESC

--10 continente con mayor cantidad de myerte (PARA VISUALES)
SELECT continent,Max(CAST(total_deaths AS int)) FROM `Covid19.COVID_DEATH`
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Max(CAST(total_deaths AS int)) DESC

--10 continente con mayor cantidad de myertes reformulacion
SELECT location,Max(total_deaths) FROM `Covid19.COVID_DEATH`
WHERE continent IS NULL
GROUP BY location
ORDER BY Max(total_deaths) DESC

--11 cifras globales
--11.1 tasa de muertes nivel global
SELECT date, sum(new_cases) AS Casos_totales, SUM(new_deaths),(SUM(new_deaths)/sum(new_cases))*100  --, (total_deaths/total_cases)*100 AS Tasa_Mortalidad 
FROM `Covid19.COVID_DEATH`
WHERE continent is not null
Group BY date
ORDER BY date ASC

--11.2 VER EL NUMERO DE CASOS, LAS MUERTES Y EL % DE MORTALDIAD POR COVID GLOBAL
SELECT sum(new_cases) AS TOTAL_CASOS, sum(new_deaths) AS TOTAL_MUERTES, (sum(new_deaths)/sum(new_cases))*100 AS PORCENTAJE_MORTALIDAD FROM `Covid19.COVID_DEATH`
WHERE continent is not null

--12 Uniendo ambas tablas
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations 
FROM `Covid19.COVID_DEATH` dea JOIN `Covid19.COVID_VACCUNE` vac 
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS not NULL
ORDER BY 1,2,3

--13 PERSONAS VACUNADAS ACUMULADAS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY  dea.location, dea.date) AS VACUNACION_ACUMULADA
FROM `Covid19.COVID_DEATH` dea JOIN `Covid19.COVID_VACCUNE` vac 
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS not NULL
ORDER BY 1,2,3

--14(CTE)
WITH POBVSVAC( dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, VACUNACION_ACUMULADA)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations , 
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY  dea.location, dea.date) AS VACUNACION_ACUMULADA
FROM `Covid19.COVID_DEATH` dea JOIN `Covid19.COVID_VACCUNE` vac 
ON dea.location=vac.location AND dea.date=vac.date
WHERE dea.continent IS not NULL
)
SELECT * FROM POBVSVAC

WITH POBVSVAC AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VACUNACION_ACUMULADA
  FROM `Covid19.COVID_DEATH` dea 
  JOIN `Covid19.COVID_VACCUNE` vac 
    ON dea.location=vac.location AND dea.date=vac.date
  WHERE dea.continent IS not NULL
)

SELECT *, (VACUNACION_ACUMULADA/population)*100 AS Porcentaje_Vacunacion_Acumulada FROM POBVSVAC ;

-- TABLA TEPORAL:
DROP TABLE IF EXISTS `covid19.Porcentaje_poblacion_vacunada`
CREATE TEMP TABLE Porcentaje_poblacion_vacunada
(
  continent STRING,
  location STRING,
  date DATE,
  population NUMERIC,
  new_vaccinations NUMERIC,
  VACUNACION_ACUMULADA NUMERIC
);

INSERT INTO Porcentaje_poblacion_vacunada
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS VACUNACION_ACUMULADA
  FROM `Covid19.COVID_DEATH` dea 
  JOIN `Covid19.COVID_VACCUNE` vac 
    ON dea.location=vac.location AND dea.date=vac.date
  WHERE dea.continent IS not NULL;
SELECT *, (VACUNACION_ACUMULADA/population)*100 AS Porcentaje_Vacunacion_Acumulada FROM Porcentaje_poblacion_vacunada ;

--CREAR VISTA PARA ALMACENAR DATOS PARA VISUALIZACIONES
DROP VIEW IF EXISTS `Covid19.TotalMuertes`;
CREATE VIEW `Covid19.TotalMuertes` AS
SELECT 
  location,
  SUM(new_deaths) AS total_muertes_acumuladas
FROM `Covid19.COVID_DEATH`
WHERE continent IS NOT NULL
GROUP BY location;
--CONSULTARLA
SELECT * FROM `Covid19.TotalMuertes`
ORDER BY total_muertes_acumuladas DESC
LIMIT 1
