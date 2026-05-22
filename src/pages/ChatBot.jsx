import { useMemo, useState } from 'react';
import { Send, MessagesSquare, MapPin, HeartPulse } from 'lucide-react';
import './ChatBot.css';

const locationCenters = {
  Colombo: [
    { name: 'Asiri Central Hospital', address: 'No. 340, Union Place, Colombo 2', phone: '+94 11 545 0000' },
    { name: 'Lanka Hospitals', address: '5, Sir Suleman Street, Colombo 2', phone: '+94 11 754 0202' },
    { name: 'Durdans Hospital', address: '2, Alfred House Gardens, Colombo 3', phone: '+94 11 268 8989' },
  ],
  Kandy: [
    { name: 'Kandy National Hospital', address: 'Gannoruwa, Kandy', phone: '+94 81 222 6020' },
    { name: 'Durdans Hospital Kandy', address: '2/1, Gannoruwa Road, Kandy', phone: '+94 81 222 8989' },
    { name: 'Teaching Hospital Kandy', address: 'Gannoruwa, Kandy', phone: '+94 81 247 9000' },
  ],
  Galle: [
    { name: 'Southern Hospital', address: '342, Galle Road, Galle', phone: '+94 91 223 4545' },
    { name: 'Galle General Hospital', address: 'Galle', phone: '+94 91 223 1660' },
    { name: 'Karapitiya Teaching Hospital', address: 'Karapitiya, Galle', phone: '+94 91 222 2084' },
  ],
  Jaffna: [
    { name: 'Jaffna Teaching Hospital', address: 'K.K.S Road, Jaffna', phone: '+94 21 222 1511' },
    { name: 'Acute Care Hospital Jaffna', address: 'Jaffna', phone: '+94 21 224 0095' },
  ],
  Trincomalee: [
    { name: 'Trincomalee Hospital', address: 'Trincomalee', phone: '+94 26 222 2222' },
    { name: 'Padaviya Hospital', address: 'Padaviya, Trincomalee', phone: '+94 26 226 3145' },
  ],
};

const sriLankaRegions = {
  Western: {
    Colombo: ['Colombo', 'Dehiwala-Mount Lavinia', 'Moratuwa', 'Negombo'],
    Gampaha: ['Gampaha', 'Wattala', 'Ja-Ela', 'Negombo'],
    Kalutara: ['Kalutara', 'Panadura', 'Horana', 'Mathugama'],
  },
  Central: {
    Kandy: ['Kandy', 'Peradeniya', 'Nawalapitiya', 'Gampola'],
    Matale: ['Matale', 'Dambulla', 'Rattota', 'Naula'],
    'Nuwara Eliya': ['Nuwara Eliya', 'Hatton', 'Nanuoya', 'Kotagala'],
  },
  Southern: {
    Galle: ['Galle', 'Hikkaduwa', 'Ambalangoda', 'Bentota'],
    Matara: ['Matara', 'Weligama', 'Deniyaya', 'Dickwella'],
    Hambantota: ['Hambantota', 'Tangalle', 'Tissamaharama', 'Beliatta'],
  },
  Northern: {
    Jaffna: ['Jaffna', 'Point Pedro', 'Chavakachcheri', 'Karainagar'],
    Kilinochchi: ['Kilinochchi', 'Poonakary', 'Paranthan', 'Pachchilaipalli'],
    Mannar: ['Mannar', 'Madhu', 'Vankalai', 'Erukkalampiddy'],
    Mullaitivu: ['Mullaitivu', 'Puthukkudiyiruppu', 'Oddusuddan', 'Mankulam'],
    Vavuniya: ['Vavuniya', 'Venkalacheddikulam', 'Omanthai', 'Mannar'],
  },
  Eastern: {
    Trincomalee: ['Trincomalee', 'Nilaveli', 'Kinniya', 'Muttur'],
    Batticaloa: ['Batticaloa', 'Eravur', 'Kaluwanchikudy', 'Valaichchenai'],
    Ampara: ['Ampara', 'Kalmunai', 'Mahaoya', 'Akkaraipattu'],
  },
  'North Western': {
    Kurunegala: ['Kurunegala', 'Kuliyapitiya', 'Nikaweratiya', 'Maho'],
    Puttalam: ['Puttalam', 'Chilaw', 'Wennappuwa', 'Kalpitiya'],
  },
  'North Central': {
    Anuradhapura: ['Anuradhapura', 'Mihintale', 'Kekirawa', 'Galenbindunuwewa'],
    Polonnaruwa: ['Polonnaruwa', 'Habarana', 'Minneriya', 'Medirigiriya'],
  },
  Uva: {
    Badulla: ['Badulla', 'Bandarawela', 'Hali-ela', 'Passara'],
    Monaragala: ['Monaragala', 'Wellawaya', 'Bibile', 'Kataragama'],
  },
  Sabaragamuwa: {
    Kegalle: ['Kegalle', 'Mawanella', 'Aranayake', 'Rambukkana'],
    Ratnapura: ['Ratnapura', 'Balangoda','Belihuloya', 'Pelmadulla', 'Embilipitiya'],
  },
};

const formatCenterList = (location) => {
  const centers = locationCenters[location];

  if (!centers) {
    return `I don't have specific hospital data for ${location} yet, but here are trusted centers in Colombo, Sri Lanka:\n\n${locationCenters.Colombo
      .map((center) => `• ${center.name} – ${center.address} (Tel: ${center.phone})`)
      .join('\n')}\n\nPlease call ahead to confirm availability and let them know if you have symptoms like chest pain, shortness of breath, or dizziness.`;
  }

  return `Here are trusted hospitals and cardiology centers in ${location}, Sri Lanka:\n\n${centers
    .map((center) => `• ${center.name} – ${center.address} (Tel: ${center.phone})`)
    .join('\n')}\n\nPlease call ahead to confirm availability and let them know if you have symptoms like chest pain, shortness of breath, or dizziness.`;
};

const fallbackResponse = `I'm here to support you with recommendations and Sri Lanka care location guidance.\nPlease ask about hospitals, clinics, cardiology advice, or patient support, and I will help as best as I can.`;

const getBotResponse = (message, location) => {
  const normalized = message.toLowerCase();
  const cityMatch = ['colombo', 'kandy', 'galle', 'jaffna', 'trincomalee'].find((city) => normalized.includes(city));
  const selectedLocation = cityMatch ? cityMatch.charAt(0).toUpperCase() + cityMatch.slice(1) : location;

  if (/\b(hospital|medical center|clinic|emergency|center|nearby|nearest|around me|location|sri lanka|sri lankan)\b/.test(normalized)) {
    return formatCenterList(selectedLocation);
  }

  if (/\b(recommendation|advice|suggestion|plan|treatment|next steps)\b/.test(normalized)) {
    return `I can help with cardiology recommendations in Sri Lanka.\n\n• Stay hydrated and avoid excessive caffeine and salty foods.\n• Monitor your blood pressure and heart rate regularly.\n• Keep a record of any chest pain, breathlessness, or swelling.\n\nIf symptoms worsen, visit the nearest emergency department immediately, especially if you feel crushing chest pain, fainting, or sudden palpitations.`;
  }

  if (/\b(heart|cardio|rhythm|afib|arrhythmia|stroke|hypertension)\b/.test(normalized)) {
    return `For heart-related concerns, these steps are important:\n\n• Book a cardiology consultation at a trusted center in ${selectedLocation}.\n• Share your ECG report and symptom history with the doctor.\n• Follow prescribed medications and lifestyle changes carefully.\n\nIf you feel a rapid or irregular heartbeat, seek medical attention immediately.`;
  }

  return fallbackResponse;
};

const ChatBot = () => {
  const [input, setInput] = useState('');
  const [selectedProvince, setSelectedProvince] = useState('Western');
  const [selectedDistrict, setSelectedDistrict] = useState('Colombo');
  const [selectedCity, setSelectedCity] = useState('Colombo');
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      text: 'Hello! I am your CardioSense assistant. Ask me for Sri Lanka hospital locations, medical center recommendations, or cardiology care guidance.',
    },
  ]);

  const quickActions = useMemo(
    () => [
      'Find hospitals in Colombo',
      'Recommend a cardiology center in Kandy',
      'What should I do for chest pain?',
      'Show medical centers near me',
    ],
    [],
  );

  const districtOptions = Object.keys(sriLankaRegions[selectedProvince] || {});
  const cityOptions = sriLankaRegions[selectedProvince]?.[selectedDistrict] || [];

  const handleProvinceChange = (value) => {
    const districts = Object.keys(sriLankaRegions[value] || {});
    const nextDistrict = districts[0] || '';
    const nextCity = sriLankaRegions[value]?.[nextDistrict]?.[0] || '';
    setSelectedProvince(value);
    setSelectedDistrict(nextDistrict);
    setSelectedCity(nextCity);
  };

  const handleDistrictChange = (value) => {
    const nextCity = sriLankaRegions[selectedProvince]?.[value]?.[0] || '';
    setSelectedDistrict(value);
    setSelectedCity(nextCity);
  };

  const handleSend = () => {
    if (!input.trim()) return;

    const userMessage = { role: 'user', text: input.trim() };
    const botMessage = { role: 'assistant', text: getBotResponse(input.trim(), selectedCity) };

    setMessages((prev) => [...prev, userMessage, botMessage]);
    setInput('');
  };

  const handleQuickAction = (text) => {
    const userMessage = { role: 'user', text };
    const botMessage = { role: 'assistant', text: getBotResponse(text, selectedCity) };
    setMessages((prev) => [...prev, userMessage, botMessage]);
  };

  return (
    <div className="chat-page">
      <div className="chat-sidebar-card">
        <div className="chat-sidebar-header">
          <MessagesSquare size={18} />
          <div>
            <h2>AI Assistant</h2>
            <p>Ask about hospitals, cardiology care, or next steps.</p>
          </div>
        </div>

        <div className="chat-location-group">
          <label>
            Province
            <select
              value={selectedProvince}
              onChange={(event) => handleProvinceChange(event.target.value)}
            >
              {Object.keys(sriLankaRegions).map((province) => (
                <option key={province} value={province}>
                  {province}
                </option>
              ))}
            </select>
          </label>

          <label>
            District
            <select
              value={selectedDistrict}
              onChange={(event) => handleDistrictChange(event.target.value)}
            >
              {districtOptions.map((district) => (
                <option key={district} value={district}>
                  {district}
                </option>
              ))}
            </select>
          </label>

          <label>
            City
            <select value={selectedCity} onChange={(event) => setSelectedCity(event.target.value)}>
              {cityOptions.map((city) => (
                <option key={city} value={city}>
                  {city}
                </option>
              ))}
            </select>
          </label>
        </div>

        <div className="chat-suggestions">
          <h3>Quick actions</h3>
          <div className="suggestion-grid">
            {quickActions.map((action) => (
              <button key={action} type="button" onClick={() => handleQuickAction(action)}>
                {action}
              </button>
            ))}
          </div>
        </div>

        <div className="chat-info">
          <div>
            <HeartPulse size={18} color="#0A66C2" />
            <p>Medical and location guidance; not a replacement for professional healthcare advice.</p>
          </div>
          <div>
            <MapPin size={18} color="#0A66C2" />
            <p>Use this tool to find trusted hospitals and clinics near you.
            </p>
          </div>
        </div>
      </div>

      <div className="chat-window-card">
        <div className="chat-window-header">
          <h2>CardioSense AI Chat</h2>
          <p>Type your question below and receive immediate guidance.</p>
        </div>

        <div className="chat-messages">
          {messages.map((message, index) => (
            <div key={index} className={`chat-message ${message.role}`}>
              <span>{message.text}</span>
            </div>
          ))}
        </div>

        <div className="chat-input-area">
          <input
            type="text"
            placeholder="Ask for hospital locations, treatment advice, or medical centers..."
            value={input}
            onChange={(event) => setInput(event.target.value)}
            onKeyDown={(event) => {
              if (event.key === 'Enter') {
                event.preventDefault();
                handleSend();
              }
            }}
          />
          <button type="button" className="send-button" onClick={handleSend}>
            <Send size={18} />
          </button>
        </div>
      </div>
    </div>
  );
};

export default ChatBot;
