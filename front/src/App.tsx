import { useEffect, useState } from 'react';
import './App.css';

interface User {
  id: number;
  name: string;
  age: number;
}

export function App() {
  const [users, setUsers] = useState<User[] | null>(null);

  useEffect(() => {
    fetch('https://api.3deploy.shop/api/users')
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
          <section>id: {user.name}</section>
          <section>id: {user.age}</section>
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
      <h1>Parcel React App test STAGING</h1>
    </>
  );
}
