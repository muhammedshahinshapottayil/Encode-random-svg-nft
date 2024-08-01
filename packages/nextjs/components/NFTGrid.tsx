import Card from "./Card";

function NFTGrid({ noOfTokens }: { noOfTokens: bigint | undefined }) {
  if (noOfTokens === undefined || noOfTokens === BigInt(0)) {
    return (
      <div className="flex justify-center items-center h-64">
        <p className="text-2xl text-gray-500">No NFTs minted yet.</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-12">
      {[...Array(Number(noOfTokens))].map((_, index) => (
        <Card key={index} id={index} />
      ))}
    </div>
  );
}

export default NFTGrid;
