// https://github.com/subquery/subql/issues/1277#issuecomment-1404181415
import { atob } from 'abab';
global.atob = atob as any;

//Exports all handler functions
export * from "./mappings/mappingHandlers";
