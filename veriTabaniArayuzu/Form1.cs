using Npgsql;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace vtysodev
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        NpgsqlConnection baglantı = new NpgsqlConnection("server=localHost; port=5432; Database=dbvtysodev; user Id=postgres; password=canoz133");

        private void Form1_Load(object sender, EventArgs e)
        {
            baglantı.Open();
            NpgsqlDataAdapter d1 = new NpgsqlDataAdapter("select * from kaynak", baglantı);
            DataTable dt = new DataTable();
            d1.Fill(dt);
            comboBox1.DisplayMember = "kaynakTurAd";
            comboBox1.ValueMember = "kaynakTurid";
            comboBox1.DataSource = dt;
            baglantı.Close();


            baglantı.Open();
            NpgsqlDataAdapter d2 = new NpgsqlDataAdapter("select * from yuzeyislemesi", baglantı);
            DataTable ds = new DataTable();
            d2.Fill(ds);
            comboBox2.DisplayMember = "islemeTurAd";
            comboBox2.ValueMember = "islemeTurid";
            comboBox2.DataSource = ds;
            baglantı.Close();


            baglantı.Open();
            NpgsqlDataAdapter d3 = new NpgsqlDataAdapter("select * from kategori", baglantı);
            DataTable dm = new DataTable();
            d3.Fill(dm);
            comboBox3.DisplayMember = "kategoriAd";
            comboBox3.ValueMember = "kategoriid";
            comboBox3.DataSource = dm;
            baglantı.Close();


            baglantı.Open();
            NpgsqlDataAdapter d4 = new NpgsqlDataAdapter("select * from tabaklamatur", baglantı);
            DataTable dd = new DataTable();
            d4.Fill(dd);
            comboBox4.DisplayMember = "tabaklamaTurAd";
            comboBox4.ValueMember = "tabaklamaTurid";
            comboBox4.DataSource = dd;
            baglantı.Close();
        }

        private void BtnListele_Click(object sender, EventArgs e)
        {
            string listeleme = "select * from deriurun";
            NpgsqlDataAdapter da = new NpgsqlDataAdapter(listeleme, baglantı);
            DataSet ds = new DataSet();
            da.Fill(ds);
            dataGridView1.DataSource = ds.Tables[0];
        }

        private void BtnEkle_Click(object sender, EventArgs e)
        {
            baglantı.Open();
            NpgsqlCommand ekleme = new NpgsqlCommand("insert into deriurun(urunid,kategoriid,tabaklamaid,kaynakid,yuzeyid,stokmiktari,satisfiyati,urunad)  values(@p1,@p2,@p3,@p4,@p5,@p6,@p7,@p8)", baglantı);

            ekleme.Parameters.AddWithValue("@p1", int.Parse(Txturetilenurunid.Text));
            ekleme.Parameters.AddWithValue("@p2", int.Parse(comboBox3.SelectedValue.ToString()));
            ekleme.Parameters.AddWithValue("@p3", int.Parse(comboBox4.SelectedValue.ToString()));
            ekleme.Parameters.AddWithValue("@p4", int.Parse(comboBox1.SelectedValue.ToString()));
            ekleme.Parameters.AddWithValue("@p5", int.Parse(comboBox2.SelectedValue.ToString()));
            ekleme.Parameters.AddWithValue("@p6", int.Parse(numericUpDown1.Value.ToString()));
            ekleme.Parameters.AddWithValue("@p7", int.Parse(Txtsatisfiyat.Text));
            ekleme.Parameters.AddWithValue("@p8", Txturunad.Text);


            ekleme.ExecuteNonQuery();
            baglantı.Close();
            MessageBox.Show("urun ekleme işlemi başarılı bir şekilde gerçekleştir");
        }

        private void Btnguncelle_Click(object sender, EventArgs e)
        {
            baglantı.Open();
            NpgsqlCommand guncelle = new NpgsqlCommand("Update deriurun set kategoriid=@p2,tabaklamaid=@p3,kaynakid=@p4,yuzeyid=@p5, stokmiktari=@p6, satisfiyati=@p7,urunad=@p8 where urunid=@p1", baglantı);
            guncelle.Parameters.AddWithValue("@p1", int.Parse(Txturetilenurunid.Text));
            guncelle.Parameters.AddWithValue("@p2", int.Parse(comboBox3.SelectedValue.ToString()));
            guncelle.Parameters.AddWithValue("@p3", int.Parse(comboBox4.SelectedValue.ToString()));
            guncelle.Parameters.AddWithValue("@p4", int.Parse(comboBox1.SelectedValue.ToString()));
            guncelle.Parameters.AddWithValue("@p5", int.Parse(comboBox2.SelectedValue.ToString()));
            guncelle.Parameters.AddWithValue("@p6", int.Parse(numericUpDown1.Value.ToString()));
            guncelle.Parameters.AddWithValue("@p7", int.Parse(Txtsatisfiyat.Text));
            guncelle.Parameters.AddWithValue("@p8", Txturunad.Text);

            guncelle.ExecuteNonQuery();
            baglantı.Close();
            MessageBox.Show("Guncelleme islemi tamamlandı");
            
        }

        private void BtnSil_Click(object sender, EventArgs e)
        {
            baglantı.Open();
            NpgsqlCommand silme = new NpgsqlCommand("Delete from deriurun Where urunid =@p1", baglantı);
            silme.Parameters.AddWithValue("@p1", int.Parse(Txturetilenurunid.Text));
            silme.ExecuteNonQuery();
            baglantı.Close();
            MessageBox.Show("Silme İslemi Basariyla Tamamlandı", "Bilgi", MessageBoxButtons.YesNo, MessageBoxIcon.Stop);
        }

        private void button1_Click(object sender, EventArgs e)
        {
            
        }

        private void button2_Click(object sender, EventArgs e)
        {
            Close();
            
        }

        private void button3_Click(object sender, EventArgs e)
        {
            Tablolar tablo = new Tablolar();
            tablo.Show();
        }
    }
}
