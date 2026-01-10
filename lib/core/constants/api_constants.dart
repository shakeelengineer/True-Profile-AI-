class ApiConstants {
  // --- IP CONFIGURATION ---
  // When you change Wi-Fi, update this IP address from 'ipconfig'
  static const String localIp = '192.168.10.6';
  
  // --- PORTS ---
  static const String port = '8000';
  
  // --- BASE URLS ---
  static const String baseUrl = 'http://$localIp:$port';
  
  // Render.com Fallback for Resume Analysis
  static const String renderUrl = 'https://ats-resume-service.onrender.com';
}
