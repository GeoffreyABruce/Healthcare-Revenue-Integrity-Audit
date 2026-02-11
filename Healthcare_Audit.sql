/* PROJECT: Inpatient Data Integrity & Financial Risk Audit
SCALE: 650MB Enterprise Healthcare Dataset (~1M+ Records)
OBJECTIVE: 
  1. Identify "Ghost Claims" (Reimbursed claims with NULL physician attribution).
  2. Quantify total financial exposure (Revenue at Risk).
  3. Perform Geographic Correlation to identify regional failure hotspots.
*/

-- QUERY 1: Detailed Detection (Isolating the 101 Corrupted Records)
-- Purpose: Provides the raw evidence/receipts for the 101 claims missing all 3 physician fields.
SELECT 
    ClaimID, 
    InscClaimAmtReimbursed,
    AttendingPhysician,
    OperatingPhysician,
    OtherPhysician
FROM Inpatient_Clean
WHERE AttendingPhysician IS NULL 
  AND OperatingPhysician IS NULL 
  AND OtherPhysician IS NULL 
  AND InscClaimAmtReimbursed > 0
  ;

-- QUERY 2: Impact Summary (Quantifying the $1.15M Revenue at Risk)
-- Purpose: Aggregates the audit findings into an executive summary of financial damage.
SELECT 
    COUNT(ClaimID) AS Total_Cases,
    SUM(InscClaimAmtReimbursed) AS Total_Amount_At_Risk,
    ROUND(AVG(InscClaimAmtReimbursed), 2) AS Average_Claim_Value
FROM Inpatient_Clean
WHERE AttendingPhysician IS NULL 
  AND OperatingPhysician IS NULL 
  AND OtherPhysician IS NULL 
  AND InscClaimAmtReimbursed > 0
  ;

-- QUERY 3: Geographic Correlation (Ranking Regional Risk across 32 States)
-- Purpose: Identifies high-value hotspots (e.g., State 45) where data corruption is most expensive.
SELECT 
    B.State, 
    COUNT(I.ClaimID) AS Error_Count,
    SUM(I.InscClaimAmtReimbursed) AS Total_Revenue_At_Risk
FROM Inpatient_Clean I
JOIN Beneficiary_Clean B ON I.BeneID = B.BeneID
WHERE I.AttendingPhysician IS NULL 
  AND I.OperatingPhysician IS NULL 
  AND I.OtherPhysician IS NULL 
  AND I.InscClaimAmtReimbursed > 0
GROUP BY B.State
ORDER BY Total_Revenue_At_Risk DESC
;