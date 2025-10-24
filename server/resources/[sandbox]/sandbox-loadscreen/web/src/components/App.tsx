import React, { useState, useEffect } from "react";
import "./App.css";
import { debugData } from "../utils/debugData";
import logo from "../images/logo.png";
import image1 from "../images/image_01.png";
import image2 from "../images/image_02.png";
import image3 from "../images/image_03.png";
import image4 from "../images/image_04.png";
import image5 from "../images/image_05.png";
import image6 from "../images/image_06.png";

const backgroundImages = [image1, image2, image3, image4, image5, image6];

debugData([{ action: "startDataFileEntries", data: {} }], 500);
debugData([{ action: "onDataFileEntry", data: "world_data.rpf" }], 1000);
debugData([{ action: "onDataFileEntry", data: "someFile.rpf" }], 1500);
debugData([{ action: "onDataFileEntry", data: "someOtherFile.rpf" }], 2000);
debugData([{ action: "endDataFileEntries", data: {} }], 2500);
debugData([{ action: "startInitFunction", data: {} }], 3000);
debugData([{ action: "startInitFunctionOrder", data: {} }], 3500);
debugData([{ action: "initFunctionInvoking", data: "session" }], 4000);
debugData([{ action: "initFunctionInvoked", data: "session" }], 4500);
debugData([{ action: "initFunctionInvoking", data: "game" }], 5000);
debugData([{ action: "initFunctionInvoked", data: "game" }], 5500);
debugData([{ action: "performMapLoadFunction", data: {} }], 6000);
debugData([{ action: "initFunctionInvoking", data: "network" }], 6500);
debugData([{ action: "initFunctionInvoked", data: "network" }], 7000);
debugData([{ action: "endInitFunction", data: { type: "session" } }], 7500);

const App: React.FC = () => {
  const [playerName, setPlayerName] = useState<string>("Player");
  const [loadingText, setLoadingText] = useState<string>("Initializing...");
  const [loadProgress, setLoadProgress] = useState<number>(0);
  const [currentBgIndex, setCurrentBgIndex] = useState<number>(0);
  const [loadingPhase, setLoadingPhase] = useState<string>("");
  const [completedPhases, setCompletedPhases] = useState<Set<string>>(new Set());

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (!event.data || typeof event.data !== "object") {
        return;
      }

      const { eventName, action, data } = event.data;
      const eventType = eventName || action;

      switch (eventType) {
        case "loadProgress":
          if (data && typeof data.loadFraction === "number") {
            setLoadProgress((prev) => Math.max(prev, data.loadFraction * 100));
          } else {
            setLoadProgress((prev) => Math.min(prev + 0.5, 100));
          }
          break;
        case "onDataFileEntry":
          if (data) {
            setLoadingText(`Loading ${data}...`);
          } else {
            setLoadingText("Loading game data...");
          }
          break;
        case "performMapLoadFunction":
          setLoadingText("Loading map...");
          setCompletedPhases((prev) => {
            if (!prev.has("mapLoad")) {
              setLoadProgress((current) => Math.max(current, 70));
              return new Set([...prev, "mapLoad"]);
            }
            return prev;
          });
          break;
        case "startDataFileEntries":
          setLoadingText("Loading game data...");
          setCompletedPhases((prev) => {
            if (!prev.has("dataStart")) {
              setLoadProgress(10);
              return new Set([...prev, "dataStart"]);
            }
            return prev;
          });
          setLoadingPhase("data");
          break;
        case "endDataFileEntries":
          setLoadingText("Data loaded, initializing...");
          setCompletedPhases((prev) => {
            if (!prev.has("dataEnd")) {
              setLoadProgress(30);
              return new Set([...prev, "dataEnd"]);
            }
            return prev;
          });
          setLoadingPhase("init");
          break;
        case "startInitFunction":
          setLoadingText("Starting initialization...");
          setCompletedPhases((prev) => {
            if (!prev.has("initStart")) {
              setLoadProgress(40);
              return new Set([...prev, "initStart"]);
            }
            return prev;
          });
          break;
        case "startInitFunctionOrder":
          setLoadingText("Starting game functions...");
          setCompletedPhases((prev) => {
            if (!prev.has("functionOrder")) {
              setLoadProgress(50);
              return new Set([...prev, "functionOrder"]);
            }
            return prev;
          });
          break;
        case "initFunctionInvoking":
          if (data && typeof data === "string") {
            setLoadingText(`Initializing ${data}...`);
          } else if (data && data.name) {
            setLoadingText(`Initializing ${data.name}...`);
          } else {
            setLoadingText("Initializing game systems...");
          }
          setCompletedPhases((prev) => {
            if (!prev.has("functionInvoking")) {
              setLoadProgress(60);
              return new Set([...prev, "functionInvoking"]);
            }
            return prev;
          });
          break;
        case "initFunctionInvoked":
          if (data && typeof data === "string") {
            setLoadingText(`Initialized ${data}...`);
          } else if (data && data.name) {
            setLoadingText(`Initialized ${data.name}...`);
          } else {
            setLoadingText("System initialized...");
          }
          setCompletedPhases((prev) => {
            if (!prev.has("functionInvoked")) {
              setLoadProgress(80);
              return new Set([...prev, "functionInvoked"]);
            }
            return prev;
          });
          break;
        case "endInitFunction":
          if (data && data.type) {
            setLoadingText(`Completed ${data.type} initialization...`);
          } else {
            setLoadingText("Finalizing...");
          }
          setCompletedPhases((prev) => {
            if (!prev.has("initEnd")) {
              setLoadProgress(100);
              return new Set([...prev, "initEnd"]);
            }
            return prev;
          });
          setLoadingPhase("complete");
          break;
      }
    };

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, []);

  useEffect(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const nameFromUrl = urlParams.get("name");
    if (nameFromUrl) {
      setPlayerName(nameFromUrl);
    } else {
      setPlayerName("AutLaaw");
    }
  }, []);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentBgIndex((prev) => {
        const availableIndices = backgroundImages.map((_, index) => index).filter((index) => index !== prev);

        const randomIndex = availableIndices[Math.floor(Math.random() * availableIndices.length)];
        return randomIndex;
      });
    }, 5000);

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="loading-screen">
      <div
        className="background-slider"
        style={{
          backgroundImage: `url(${backgroundImages[currentBgIndex]})`,
        }}
      />
      <div className="background-overlay" />

      <div className="center-content">
        <img src={logo} alt="Logo" className="logo" />
        <div className="welcome-text">
          <h1 className="player-name">{playerName}</h1>
          <h2 className="welcome-message">
            Welcome to Sandbox
            <span className="dots">
              <span className="dot">.</span>
              <span className="dot">.</span>
              <span className="dot">.</span>
            </span>
          </h2>
        </div>
      </div>

      <div className="bottom-content">
        <div className="loading-info">
          <p className="loading-text">{loadingText}</p>
        </div>
        <div className="progress-bar-container">
          <div className="progress-bar-fill" style={{ width: `${loadProgress}%` }} />
        </div>
      </div>
    </div>
  );
};

export default App;
