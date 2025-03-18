import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function getAge(birthday: string) {
  const today = new Date();
  const date = birthday.split(" ")[0]
  const year = date.split("-")[0]
  const month = date.split("-")[1]
  const day = date.split("-")[2]
  const birthDate = new Date(parseInt(year), parseInt(month) - 1, parseInt(day));
  let age = today.getFullYear() - birthDate.getFullYear();
  const m = today.getMonth() - birthDate.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
    age--;
  }
  return age;
}