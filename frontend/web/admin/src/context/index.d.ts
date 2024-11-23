import { ReactNode, Dispatch } from 'react';

interface MaterialUIContextType {
  miniSidenav: boolean;
  transparentSidenav: boolean;
  whiteSidenav: boolean;
  sidenavColor: string;
  transparentNavbar: boolean;
  fixedNavbar: boolean;
  openConfigurator: boolean;
  direction: string;
  layout: string;
  darkMode: boolean;
}

type MaterialUIActionType =
  | { type: 'MINI_SIDENAV'; value: boolean }
  | { type: 'TRANSPARENT_SIDENAV'; value: boolean }
  | { type: 'WHITE_SIDENAV'; value: boolean }
  | { type: 'SIDENAV_COLOR'; value: string }
  | { type: 'TRANSPARENT_NAVBAR'; value: boolean }
  | { type: 'FIXED_NAVBAR'; value: boolean }
  | { type: 'OPEN_CONFIGURATOR'; value: boolean }
  | { type: 'DIRECTION'; value: string }
  | { type: 'LAYOUT'; value: string }
  | { type: 'DARKMODE'; value: boolean };

export const MaterialUIControllerProvider: React.FC<{ children: ReactNode }>;
export function useMaterialUIController(): [MaterialUIContextType, Dispatch<MaterialUIActionType>];
export function setMiniSidenav(dispatch: Dispatch<MaterialUIActionType>, value: boolean): void;
export function setTransparentSidenav(dispatch: Dispatch<MaterialUIActionType>, value: boolean): void;
export function setWhiteSidenav(dispatch: Dispatch<MaterialUIActionType>, value: boolean): void;
export function setSidenavColor(dispatch: Dispatch<MaterialUIActionType>, value: string): void;
export function setTransparentNavbar(dispatch: Dispatch<MaterialUIActionType>, value: boolean): void;
export function setFixedNavbar(dispatch: Dispatch<MaterialUIActionType>, value: boolean): void;
export function setOpenConfigurator(dispatch: Dispatch<MaterialUIActionType>, value: boolean): void;
export function setDirection(dispatch: Dispatch<MaterialUIActionType>, value: string): void;
export function setLayout(dispatch: Dispatch<MaterialUIActionType>, value: string): void;
export function setDarkMode(dispatch: Dispatch<MaterialUIActionType>, value: boolean): void;
