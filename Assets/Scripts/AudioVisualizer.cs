using UnityEngine;

[RequireComponent(typeof(AudioSource))]
public class AudioVisualizer : MonoBehaviour
{
    public Material material;
    public float maxDisplacement = 1.0f; // Amount of displacement
    private AudioSource audioSource;
    private float[] spectrumData = new float[128]; // Ajustado para 128 amostras
    private bool isPlaying = false;

    void Start()
    {
        audioSource = GetComponent<AudioSource>();
    }

    void Update()
    {
        // Verificar se a tecla P foi pressionada para iniciar/pausar a música
        if (Input.GetKeyDown(KeyCode.P))
        {
            if (isPlaying)
            {
                audioSource.Pause();
            }
            else
            {
                audioSource.Play();
            }
            isPlaying = !isPlaying;
        }

        if (isPlaying)
        {
            // Analisar o espectro de áudio
            audioSource.GetSpectrumData(spectrumData, 0, FFTWindow.Rectangular);

            // Enviar os dados do espectro para o shader
            if (material != null)
            {
                for (int i = 0; i < spectrumData.Length; i++)
                {
                    material.SetFloat("_SpectrumData" + i, spectrumData[i]);
                }
                material.SetFloat("_Displacement", maxDisplacement);
            }
        }
    }
}

