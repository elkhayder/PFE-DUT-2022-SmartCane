import React, { useEffect, useState } from "react";

type Place = {
   id: string;
   name: string;
   address: string;
   location: {
      lat: string;
      lng: string;
   };
};

const App = () => {
   const [place, setPlace] = useState<Place | null>(null);
   const [error, setError] = useState<String | null>(null);
   const [isLoading, setIsLoading] = useState(true);

   useEffect(() => {
      fetchPlaceInfos();
   }, []);

   const fetchPlaceInfos = async () => {
      const currentUrl = new URL(window.location.href);

      const apiEndpoint = new URL(
         "https://private-no-cors-proxy.herokuapp.com/https://maps.googleapis.com/maps/api/place/details/json"
      );

      apiEndpoint.searchParams.append(
         "place_id",
         currentUrl.searchParams.get("id") ?? ""
      );

      apiEndpoint.searchParams.append(
         "key",
         "AIzaSyBqJ0ixB7WeMXMdCHq57aDErVRPQK1HGt4"
      );

      const request = await fetch(apiEndpoint.toString())
         .then((x) => x.json())
         .catch((e) => {
            setError(
               "We encountered an error while loading place infos, try to refresh the page."
            );
            return null;
         })
         .finally(() => setIsLoading(false));

      if (!request) return;

      if (request.status === "INVALID_REQUEST") {
         setError(
            "Seems like the link is broken, make sure you copied the exact one you received."
         );
         return;
      }

      setPlace({
         id: request.result.place_id,
         name: request.result.name,
         address: request.result.formatted_address,
         location: request.result.geometry.location,
      });

      console.log(place);
   };

   return (
      <section id="head">
         {isLoading && (
            <div className="lds-ring">
               <div />
               <div />
               <div />
               <div />
            </div>
         )}
         {error && <h3 className="error">{error}</h3>}
         {place && (
            <>
               <h1 className="title">{place?.name}</h1>
               <h2 className="address">{place?.address}</h2>
               <div className="row">
                  <a href={`https://guideme.elkhayder.me/?id=${place?.id}`}>
                     <button className="purple">
                        <i className="fa-solid fa-location-crosshairs fa-2x" />
                        <span>Open in GuideMe</span>
                     </button>
                  </a>
                  <a
                     href="https://github.com/elkhayder/SmartCane-PFE-2022"
                     target="_blank"
                     rel="noreferrer"
                  >
                     <button className="blue">
                        <i className="fa-brands fa-android fa-2x" />
                        <span>Download app for Android</span>
                     </button>
                  </a>
                  <a
                     href={`https://maps.google.com?q=${place.location.lat},${place.location.lng}`}
                     target="_blank"
                     rel="noreferrer"
                  >
                     <button className="green">
                        <i className="fa-solid fa-map fa-2x" />
                        <span>Open in Maps</span>
                     </button>
                  </a>
               </div>
            </>
         )}
      </section>
   );
};

export default App;