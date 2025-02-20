import React, { useState } from "react";
import "./App.css";

const App = () => {
  const [postsState] = useState([
    { id: 1, title: "First DAO", body: "This is the first DAO project." },
    { id: 2, title: "Second DAO", body: "This is another DAO concept." }
  ]);

  return (
    <div>
      {/* Header Section */}
      <header className="header">
        <nav className="nav-menu">
          <h1>InpactChain</h1>
          <a href="#create">DAO Create</a>
          <a href="#ecosystem">Ecosystem</a>
          <a href="#incubation">Incubation</a>
          <a href="#token">Token</a>
          <a href="#learn">Learn</a>
          <button className="cta-button">Wallet</button>
        </nav>
      </header>

      {/* Main Content */}
      <main className="content">
        {/* Hero Section */}
        <section id="home" className="hero">
          <div className="hero-content">
            <h1>The easiest way to start a DAO</h1>
            <p>
              An all-in-one platform to start, manage, and grow a decentralized autonomous organization.
            </p>
            <div className="cta-buttons">
              <a href="Dao.html" className="cta-button">Get Started</a>
            </div>
          </div>
        </section>

        {/* Ready for Every Project Section */}
        <section id="ready-for-every-project">
          <h2>Ready for Every Project</h2>
          <div className="button-group">
            <div className="top-row">
              <button className="cta-button">Investment DAO</button>
              <button className="cta-button">Startup DAO</button>
              <button className="cta-button">Service DAO</button>
              <button className="cta-button">Community DAO</button>
            </div>
            <div className="bottom-row">
              <button className="cta-button">Impact DAO</button>
              <button className="cta-button">DeFi DAO</button>
              <button className="cta-button">+ More</button>
            </div>
          </div>
        </section>

        {/* Image Section */}
        <section style={{ textAlign: 'center', margin: '2rem 0' }}>
          <img 
            src={`${process.env.PUBLIC_URL}/resim.png`} 
            alt="DAO concept" 
            style={{ width: '100%', maxWidth: '1000px', height: 'auto', objectFit: 'cover' }} 
          />
        </section>

        {/* Posts Section */}
        <section id="posts">
          <h2>Latest Posts</h2>
          <ul className="posts-list">
            {postsState.length > 0 ? (
              postsState.map((post) => (
                <li key={post.id}>
                  <h3>{post.title}</h3>
                  <p>{post.body}</p>
                </li>
              ))
            ) : (
              <p>No posts available.</p>
            )}
          </ul>
        </section>
      </main>
    </div>
  );
};

export default App;

