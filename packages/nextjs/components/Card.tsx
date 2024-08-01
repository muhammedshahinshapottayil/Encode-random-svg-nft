import { useScaffoldReadContract } from "~~/hooks/scaffold-eth";

function Card({ id }: { id: number }) {
  const { data: chubbiness } = useScaffoldReadContract({
    contractName: "SVGNFT",
    functionName: "chubbiness",
    args: [BigInt(id)]
  });

  const { data: color } = useScaffoldReadContract({
    contractName: "SVGNFT",
    functionName: "color",
    args: [BigInt(id)]
  });

  const { data: mouthLength } = useScaffoldReadContract({
    contractName: "SVGNFT",
    functionName: "mouthLength",
    args: [BigInt(id)]
  });

  const removeHexPrefix = (hexString: string): string => {
    if (hexString.startsWith("0x")) {
      return hexString.slice(2);
    }
    return hexString;
  }


  if (!chubbiness || !color || !mouthLength) {
    return (
      <div className="group relative overflow-hidden rounded-2xl shadow-2xl transform hover:scale-105 transition duration-300 ease-in-out bg-gray-800 w-full h-full max-w-[400px] max-h-[400px] aspect-square">
        <div className="absolute inset-0 bg-gradient-to-br from-pink-500 via-purple-500 to-indigo-500 opacity-25 group-hover:opacity-50 transition duration-300"></div>
        <div className="absolute inset-0 flex flex-col items-center justify-center text-white p-4">
          <svg className="animate-spin h-10 w-10 mb-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          <p className="text-lg font-semibold">Loading...</p>
          <p className="text-sm mt-2">Token ID: {id}</p>
        </div>
      </div>
    );
  }

  const svgString = `
    <svg width="100%" height="100%" viewBox="0 0 400 400" xmlns="http://www.w3.org/2000/svg">
      <g id="eye1">
        <ellipse stroke-width="3" ry="29.5" rx="29.5" id="svg_1" cy="154.5" cx="181.5" stroke="#000" fill="#fff" />
        <ellipse ry="3.5" rx="2.5" id="svg_3" cy="154.5" cx="173.5" stroke-width="3" stroke="#000" fill="#000000" />
      </g>
      <g id="head">
        <ellipse fill="#${removeHexPrefix(color)}" stroke-width="3" cx="204.5" cy="211.80065" id="svg_5" rx="${Number(chubbiness)}" ry="51.80065" stroke="#000" />
      </g>
      <g id="eye2">
        <ellipse stroke-width="3" ry="29.5" rx="29.5" id="svg_2" cy="168.5" cx="209.5" stroke="#000" fill="#fff" />
        <ellipse ry="3.5" rx="3" id="svg_4" cy="169.5" cx="208" stroke-width="3" fill="#000000" stroke="#000" />
      </g>
      <g class="mouth" transform="translate(${Math.floor((810 - 9 * Number(chubbiness)) / 11)},0)">
        <path d="M 130 240 Q 165 250 ${Number(mouthLength)} 235" stroke="black" stroke-width="3" fill="transparent" />
      </g>
    </svg>
  `;

  return (
    <div className="group relative overflow-hidden rounded-2xl shadow-2xl transform hover:scale-105 transition duration-300 ease-in-out w-full h-full max-w-[400px] max-h-[400px] aspect-square">
      <div className="absolute inset-0 bg-gradient-to-br from-pink-500 via-purple-500 to-indigo-500 opacity-25 group-hover:opacity-50 transition duration-300"></div>
      <div className="w-full h-full z-10 relative" dangerouslySetInnerHTML={{ __html: svgString }} />
      <div className="absolute bottom-0 left-0 right-0 p-4 text-white bg-black bg-opacity-50">
        <p className="text-lg">Token ID: {id}</p>
      </div>
    </div>
  );
}

export default Card;