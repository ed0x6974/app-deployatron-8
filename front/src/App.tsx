import { useEffect, useState } from 'react';
import './App.css';

const API_URL = process.env.PARCEL_API_URL;

interface User {
  id: number;
  name: string;
  surname: string;
}

export function App() {
  const [users, setUsers] = useState<User[] | null>(null);

  useEffect(() => {
    fetch(API_URL)
      .then((response) => {
        if (response.status === 200) {

          return response.json();
        } else {
          throw new Error(`Query error: ${response.status}`);
        }
      })
      .then((users) => {
        setUsers(users);
      })
      .catch(console.error);
  }, []);

  if (users) {
    const usersMarkup = users.map(user => {
      return (
        <article>
          <section>id: {user.id}</section>
          <section>name: {user.name}</section>
          <section>surname: {user.surname}</section>
        </article>
      )
    })

    return (
      <section>
        <h1>Users</h1>
        {usersMarkup}
      </section>
    )
  }

  return (
    <>
      <h1>Parcel React App</h1>
    </>
  );
}
