"use client";

import React, { useCallback, useRef, useState } from "react";
import Image from "next/image";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Bars3Icon, BugAntIcon } from "@heroicons/react/24/outline";
import { FaucetButton, RainbowKitCustomConnectButton } from "~~/components/scaffold-eth";
import { useOutsideClick } from "~~/hooks/scaffold-eth";

type HeaderMenuLink = {
  label: string;
  href: string;
  icon?: React.ReactNode;
};

export const menuLinks: HeaderMenuLink[] = [
  {
    label: "Home",
    href: "/",
  },
  {
    label: "Debug Contracts",
    href: "/debug",
    icon: <BugAntIcon className="h-4 w-4" />,
  },
];

export const HeaderMenuLinks = () => {
  const pathname = usePathname();

  return (
    <>
      {menuLinks.map(({ label, href, icon }) => {
        const isActive = pathname === href;
        return (
          <li key={href}>
            <Link
              href={href}
              passHref
              className={`${
                isActive ? "bg-gradient-to-r from-pink-500 via-purple-500 to-indigo-500" : ""
              } hover:bg-gradient-to-r hover:from-pink-500 hover:via-purple-500 hover:to-indigo-500 transition-all py-2 px-4 text-sm rounded-full gap-2 grid grid-flow-col text-white`}
            >
              {icon}
              <span>{label}</span>
            </Link>
          </li>
        );
      })}
    </>
  );
};

export const Header = () => {
  const [isDrawerOpen, setIsDrawerOpen] = useState(false);
  const burgerMenuRef = useRef<HTMLDivElement>(null);
  useOutsideClick(
    burgerMenuRef,
    useCallback(() => setIsDrawerOpen(false), []),
  );

  return (
    <header className="sticky top-0 z-20 py-3 bg-black bg-opacity-80 backdrop-filter backdrop-blur-lg">
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center">
          <div className="flex items-center">
            <Link href="/" passHref className="flex items-center gap-2 mr-6">
              <div className="relative w-10 h-10">
                <Image alt="Logo" className="cursor-pointer" fill src="/logo.svg" />
              </div>
              <div className="hidden sm:flex flex-col">
                <span className="font-bold text-lg bg-clip-text text-transparent bg-gradient-to-r from-pink-500 via-purple-500 to-indigo-500">
                  Optimistic Loogies
                </span>
                <span className="text-xs text-gray-300">NFT Collection</span>
              </div>
            </Link>
            <nav className="hidden lg:flex">
              <ul className="flex gap-2">
                <HeaderMenuLinks />
              </ul>
            </nav>
          </div>
          <div className="flex items-center gap-2">
            <RainbowKitCustomConnectButton />
            <FaucetButton />
            <div className="lg:hidden" ref={burgerMenuRef}>
              <button className="btn btn-ghost btn-sm" onClick={() => setIsDrawerOpen(prev => !prev)}>
                <Bars3Icon className="h-6 w-6" />
              </button>
              {isDrawerOpen && (
                <ul className="absolute right-0 mt-2 p-2 bg-black bg-opacity-90 rounded-lg shadow-lg">
                  <HeaderMenuLinks />
                </ul>
              )}
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};
