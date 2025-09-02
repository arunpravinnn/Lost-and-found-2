"use client";
import React, { useEffect, useState } from 'react';
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!;
const supabase = createClient(supabaseUrl, supabaseAnonKey);

type LostItems = {
    item_id: string;
    item_name: string;
    description: string;
    location_lost: string;
    date_lost: string;
    reported_by_name: string;
    reported_by_roll: string;
    created_post: string;
    image_url: string;
};

const LostItems: React.FC = () => {
    const [lostItems, setLostItems] = useState<LostItems[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchLostItems = async () => {
            const { data, error } = await supabase
                .from('Lost_items')
                .select('item_id, item_name, description, location_lost, date_lost, reported_by_name, reported_by_roll, created_post, image_url');
            if (!error && data) {
                setLostItems(data);
                console.log(data);
            }
            setLoading(false);
        };
        fetchLostItems();
    }, []);

    if (loading) return <div>Loading...</div>;

    return (
        <div style={{ display: 'flex', flexWrap: 'wrap', gap: '16px' }}>
            {lostItems.map(item => (
                <div
                    key={item.item_id}
                    style={{
                        border: '1px solid #ccc',
                        borderRadius: '8px',
                        padding: '16px',
                        minWidth: '220px',
                        boxShadow: '0 2px 8px rgba(0,0,0,0.05)',
                    }}
                >
                    <p className='text-md font-bold'>Item Name: {item.item_name}</p>
                    <p className='text-md font-bold'>Description: {item.description}</p>
                    <p className='text-md font-bold'>Location Lost: {item.location_lost}</p>
                    <p className='text-md font-bold'>Date Lost: {item.date_lost}</p>
                    <p className='text-md font-bold'>Reported By: {item.reported_by_name} ({item.reported_by_roll ? item.reported_by_roll : 'Unknown'})</p>
                    <p className='text-md font-bold'>Created Post: {item.created_post}</p>
                    <img src={item.image_url} alt={item.item_name} style={{ maxWidth: '100%', borderRadius: '8px' }} />
                </div>
            ))}
        </div>
    );
};

export default LostItems;