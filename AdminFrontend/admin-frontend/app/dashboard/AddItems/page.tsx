"use client";
import { useState } from "react";
import { createClient } from "@supabase/supabase-js";
import axios from "axios";



interface LostItem {
  name: string;
  description: string,
  location_lost: string,
  dateLost: Date | null | string;
  reported_by_name:string,
  securityQuestion: string;
  reported_by_roll: string,
  created_post: Date | null | string,
  answer: string;
}

export default function DashboardPage() {
  const [lostItem, setLostItem] = useState<LostItem>({
    name: "",
    description:"",
    dateLost: new Date(),
    location_lost:"",
    reported_by_name:"",
    securityQuestion: "",
    reported_by_roll:"",
    created_post: new Date(),
    answer: "",
  });

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    setLostItem({ ...lostItem, [name]: value });
  };

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const data = await axios.post('http://localhost:3000/api/add_items', lostItem);
    if (data){
        console.log("Item added successfully:", data);
    }
    setLostItem({ name: "",description:"", dateLost: null,location_lost:"",reported_by_name:"",reported_by_roll:"", securityQuestion: "", answer: "",created_post:null}); // Reset form
  };

  return (
    <div className="space-y-6 flex flex-col items-center">
        <h1 className="font-extrabold text-4xl">Enter the details of the newly lost item</h1>
      <section className="flex gap-4 lg:grid-cols-3 w-full ">
        <form onSubmit={handleSubmit} className="space-y-4 flex flex-col justify-center w-full">
          <div>
            <label htmlFor="name" className="block text-sm font-medium">Item Name</label>
            <input
              type="text"
              name="name"
              id="name"
              value={lostItem.name}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>
          <div>
            <label htmlFor="name" className="block text-sm font-medium">Description</label>
            <input
              type="text"
              name="description"
              id="description"
              value={lostItem.description}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>
          <div>
            <label htmlFor="dateLost" className="block text-sm font-medium">Date Lost</label>
            <input
              type="date"
              name="dateLost"
              id="dateLost"
              value={lostItem.dateLost}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>
          <div>
            <label htmlFor="dateLost" className="block text-sm font-medium">Created Post</label>
            <input
              type="date"
              name="created_post"
              id="created_post"
              value={lostItem.created_post = new Date()}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>
          <div>
            <label htmlFor="name" className="block text-sm font-medium">Location Lost</label>
            <input
              type="text"
              name="location_lost"
              id="location_lost"
              value={lostItem.location_lost}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>
          <div>
            <label htmlFor="name" className="block text-sm font-medium">Reported By Name</label>
            <input
              type="text"
              name="reported_by_name"
              id="reported_by_name"
              value={lostItem.reported_by_name}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>
          <div>
            <label htmlFor="name" className="block text-sm font-medium">Reported By Roll</label>
            <input
              type="text"
              name="reported_by_roll"
              id="reported_by_roll"
              value={lostItem.reported_by_roll}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>
          
          <div>
            <label htmlFor="securityQuestion" className="block text-sm font-medium">Security Question</label>
            <select
              name="securityQuestion"
              id="securityQuestion"
              value={lostItem.securityQuestion}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            >
              <option value="">Select a question</option>
              <option value="What is your pet's name?">What is your pet's name?</option>
              <option value="What is your mother's maiden name?">What is your mother's maiden name?</option>
              <option value="What was the name of your first school?">What was the name of your first school?</option>
            </select>
          </div>
          <div>
            <label htmlFor="name" className="block text-sm font-medium">Answer</label>
            <input
              type="text"
              name="answer"
              id="answer"
              value={lostItem.answer}
              onChange={handleChange}
              required
              className="mt-1 block w-full border border-gray-300 rounded-md p-2"
            />
          </div>
          <button type="submit" className="mt-4 bg-blue-500 text-white rounded-md p-2">Submit</button>
        </form>
      </section>
    </div>
  );
}