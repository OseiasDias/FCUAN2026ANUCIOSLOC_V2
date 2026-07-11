import React from 'react';
import { FaHeart } from 'react-icons/fa';
import './FooterProfissional.css';

const FooterProfissional = () => {
  const year = new Date().getFullYear();

  return (
    <footer className="footer-profissional">
      <div className="footer-content">
        <p>
          &copy; {year} <span className="footer-highlight">AnunciosLoc</span> - 
          Todos os direitos reservados
        </p>
        <p className="footer-credit">
          Feito com <FaHeart className="footer-heart" /> pela equipa AnunciosLoc
        </p>
      </div>
    </footer>
  );
};

export default FooterProfissional;