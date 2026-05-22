import { createContext, useContext, useMemo, useState, useEffect } from 'react';

const API_BASE = import.meta.env.VITE_API_URL || 'http://localhost:5001';
const ReportsContext = createContext(null);

export const ReportsProvider = ({ children }) => {
  const [reports, setReports] = useState([]);

  useEffect(() => {
    const fetchReports = async () => {
      try {
        const response = await fetch(`${API_BASE}/api/reports`);
        if (!response.ok) {
          setReports([]);
          return;
        }

        const data = await response.json();
        setReports(data);
      } catch (error) {
        setReports([]);
      }
    };

    fetchReports();
  }, []);

  const addReport = async (reportData) => {
    try {
      const response = await fetch(`${API_BASE}/api/reports`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(reportData),
      });

      if (!response.ok) {
        throw new Error('Failed to create report.');
      }

      const newReport = await response.json();
      setReports((prev) => [...prev, newReport]);
      return newReport;
    } catch (error) {
      throw error;
    }
  };

  const uploadReport = async (formData) => {
    try {
      const response = await fetch(`${API_BASE}/api/upload`, {
        method: 'POST',
        body: formData,
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.message || 'Failed to upload report.');
      }

      const newReport = await response.json();
      setReports((prev) => [...prev, newReport]);
      return newReport;
    } catch (error) {
      throw error;
    }
  };

  const getReportsByCardiologist = (cardiologistEmail) => {
    return reports.filter((report) => report.cardiologistEmail === cardiologistEmail);
  };

  const getReportsByPatient = (patientEmail) => {
    return reports.filter((report) => report.patientEmail === patientEmail);
  };

  const value = useMemo(
    () => ({
      reports,
      addReport,
      uploadReport,
      getReportsByCardiologist,
      getReportsByPatient,
    }),
    [reports],
  );

  return <ReportsContext.Provider value={value}>{children}</ReportsContext.Provider>;
};

export const useReports = () => {
  const context = useContext(ReportsContext);
  if (!context) {
    throw new Error('useReports must be used within ReportsProvider');
  }
  return context;
};
