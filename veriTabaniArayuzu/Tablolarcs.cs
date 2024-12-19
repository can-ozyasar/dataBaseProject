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

namespace dataBaseOdev
{
    public partial class Tablolarcs : Form
    {

        NpgsqlConnection baglanti = new NpgsqlConnection("server=localHost; port=5432; Database=dbvtysodev; user Id=postgres; password=canoz133");


        public Tablolarcs()
        {
            InitializeComponent();

        }
        String secili = "";
        string stun = "";
        private void BtnListele_Click(string ad)
        {

            try
            {
                string sorgu = $"SELECT * FROM {ad}";
                NpgsqlDataAdapter da = new NpgsqlDataAdapter(sorgu, baglanti);
                DataSet ds = new DataSet();
                da.Fill(ds);
                dataGridView1.DataSource = ds.Tables[0];
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
        }

        private void button1_Click(object sender, EventArgs e)
        {
            BtnListele_Click("personel"); secili = "personel"; stun = "personelAd";

        }

        private void button14_Click(object sender, EventArgs e)
        {
            BtnListele_Click("musteritemsilcileri"); secili = "musteritemsilcileri"; stun = "personelAd";

        }

        private void button13_Click(object sender, EventArgs e)
        {
            BtnListele_Click("calisan"); secili = "calisan"; stun = "personelAd";

        }

        private void button12_Click(object sender, EventArgs e)
        {
            BtnListele_Click("yonetici"); secili = "yonetici"; stun = "personelAd";

        }

        private void button11_Click(object sender, EventArgs e)
        {
            BtnListele_Click("deriurun"); secili = "deriurun"; stun = "urunad";

        }

        private void button15_Click(object sender, EventArgs e)
        {
            BtnListele_Click("kargofirmasi"); secili = "kargofirmasi"; stun = "kargoAd";

        }

        private void button8_Click(object sender, EventArgs e)
        {
            BtnListele_Click("kategori"); secili = "kategori"; stun = "kategoriAd";

        }

        private void button3_Click(object sender, EventArgs e)
        {
            BtnListele_Click("musteri"); secili = "musteri"; stun = "musteriAd";

        }

        private void button9_Click(object sender, EventArgs e)
        {
            BtnListele_Click("kaynak"); secili = "kaynak"; stun = "kaynakTurAd";

        }

        private void button5_Click(object sender, EventArgs e)
        {
            BtnListele_Click("musteribulundugubolge"); secili = "musteribulundugubolge"; stun = "bolgeAd";

        }

        private void button4_Click(object sender, EventArgs e)
        {
            BtnListele_Click("odemetur"); secili = "odemetur"; stun = "odemeTurAd";

        }

        private void button6_Click(object sender, EventArgs e)
        {
            BtnListele_Click("sehir"); secili = "sehir"; stun = "sehirAd";

        }

        private void button2_Click(object sender, EventArgs e)
        {
            BtnListele_Click("siparis"); secili = "siparis"; stun = "siparisAd";

        }

        private void button7_Click(object sender, EventArgs e)
        {
            BtnListele_Click("tabaklamatur"); secili = "tabaklamatur"; stun = "tabaklamaTurAd";

        }

        private void button10_Click(object sender, EventArgs e)
        {
            BtnListele_Click("yuzeyislemesi"); secili = "yuzeyislemesi"; stun = "islemeTurAd";

        }

        private void Tablolarcs_Load(object sender, EventArgs e)
        {

        }
        private void Listele(string tabloAdi, string filtre, int tur, string stun)
        {
            try
            {
                string sorgu = "";
                if (tur == 0) // %filtre%: Herhangi bir konumda
                {
                    sorgu = $"SELECT * FROM \"{tabloAdi}\" WHERE \"{stun}\" LIKE @filtre";
                }
                else if (tur == 1) // %filtre: Sondan başlayan eşleşme
                {
                    sorgu = $"SELECT * FROM \"{tabloAdi}\" WHERE \"{stun}\" LIKE @filtre";
                }
                else // filtre%: Baştan başlayan eşleşme
                {
                    sorgu = $"SELECT * FROM \"{tabloAdi}\" WHERE \"{stun}\" LIKE @filtre";
                }

                using (NpgsqlCommand cmd = new NpgsqlCommand(sorgu, baglanti))
                {
                    // Filtre durumuna göre parametre değeri atanıyor
                    if (tur == 0)
                        cmd.Parameters.AddWithValue("@filtre", $"%{filtre}%"); // İçinde geçen
                    else if (tur == 1)
                        cmd.Parameters.AddWithValue("@filtre", $"%{filtre}"); // Sondan başlayan
                    else
                        cmd.Parameters.AddWithValue("@filtre", $"{filtre}%"); // Baştan başlayan

                    NpgsqlDataAdapter da = new NpgsqlDataAdapter(cmd);
                    DataSet ds = new DataSet();
                    da.Fill(ds);
                    dataGridView1.DataSource = ds.Tables[0];
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message);
            }
        }
        private void button16_Click(object sender, EventArgs e)
        {
            // Textbox'tan filtre değerini al
            string filtre = txtFiltre.Text;

            // Örnek: "siparis" tablosunda filtre uygula
            Listele(secili, filtre, comboBox1.SelectedIndex, stun);
        }

        private void button17_Click(object sender, EventArgs e)
        {
            Close();
        }
    }
}
