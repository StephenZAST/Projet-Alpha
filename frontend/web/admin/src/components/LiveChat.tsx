import React, { useState } from 'react';
import styles from './style/LiveChat.module.css';

const LiveChat: React.FC = () => {
  const [messages, setMessages] = useState<string[]>([]);
  const [newMessage, setNewMessage] = useState('');

  const handleSendMessage = () => {
    setMessages([...messages, newMessage]);
    setNewMessage('');
  };

  return (
    <div className={styles.liveChatContainer}>
      <h2>Live Chat</h2>
      <div className={styles.chatMessages}>
        {messages.map((message, index) => (
          <div key={index} className={styles.message}>
            <p>{message}</p>
          </div>
        ))}
      </div>
      <input
        type="text"
        value={newMessage}
        onChange={(e) => setNewMessage(e.target.value)}
        placeholder="Type a message..."
        className={styles.messageInput}
      />
      <button onClick={handleSendMessage} className={styles.sendMessageButton}>
        Send
      </button>
    </div>
  );
};

export default LiveChat;
